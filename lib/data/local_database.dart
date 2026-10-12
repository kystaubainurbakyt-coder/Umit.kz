import 'dart:typed_data';

import 'package:sqflite_common/sqlite_api.dart';

import 'database_factory.dart';
import 'information_content.dart';

class LocalDatabase {
  LocalDatabase({this.opener = openLocalDatabase});
  final Future<Database> Function(OpenDatabaseOptions) opener;
  Database? _database;
  Database get database => _database!;

  /// Create a standalone, consistent SQLite file, including WAL changes.
  Future<Uint8List> exportBytes() async {
    final path =
        '${database.path}.export_${DateTime.now().microsecondsSinceEpoch}.db';
    try {
      await database.execute('VACUUM INTO ?', [path]);
      return await readDatabaseExport(path);
    } finally {
      await deleteDatabaseExport(path);
    }
  }

  Future<void> open() async {
    if (_database != null && database.isOpen) return;
    _database = await opener(
      OpenDatabaseOptions(
        version: 2,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE accounts (email TEXT PRIMARY KEY, name TEXT NOT NULL, hash TEXT NOT NULL, salt TEXT NOT NULL, role TEXT NOT NULL, blocked INTEGER NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE events (id INTEGER PRIMARY KEY, category TEXT NOT NULL, title TEXT NOT NULL, location TEXT NOT NULL, date TEXT NOT NULL, description TEXT NOT NULL, capacity INTEGER NOT NULL, published INTEGER NOT NULL, startsAt TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE requests (id INTEGER PRIMARY KEY, email TEXT NOT NULL REFERENCES accounts(email), eventId INTEGER NOT NULL REFERENCES events(id), status TEXT NOT NULL, note TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE notices (id INTEGER PRIMARY KEY, email TEXT NOT NULL REFERENCES accounts(email), text TEXT NOT NULL, read INTEGER NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE saved (email TEXT NOT NULL, eventId INTEGER NOT NULL REFERENCES events(id), PRIMARY KEY(email, eventId))',
          );
          await db.execute(
            'CREATE TABLE metadata (key TEXT PRIMARY KEY, value INTEGER NOT NULL)',
          );
          await db.execute('CREATE INDEX requests_owner ON requests(email)');
          await db.execute('CREATE INDEX notices_owner ON notices(email)');
          await _createReferenceTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) await _createReferenceTables(db);
        },
      ),
    );
  }

  Future<void> _createReferenceTables(Database db) async {
    await db.execute('CREATE TABLE categories (name TEXT PRIMARY KEY)');
    await db.execute('CREATE TABLE locations (name TEXT PRIMARY KEY)');
    await db.execute(
      'CREATE TABLE articles (id INTEGER PRIMARY KEY, kind TEXT NOT NULL, title TEXT NOT NULL, summary TEXT NOT NULL, source TEXT)',
    );
    await db.execute(
      'CREATE TABLE article_sections (articleId INTEGER NOT NULL REFERENCES articles(id), position INTEGER NOT NULL, title TEXT NOT NULL, body TEXT NOT NULL, PRIMARY KEY(articleId, position))',
    );
    await db.execute(
      'INSERT INTO categories(name) SELECT DISTINCT category FROM events',
    );
    await db.execute(
      'INSERT INTO locations(name) SELECT DISTINCT location FROM events',
    );
    var id = 0;
    for (final group in {
      'information': informationArticles,
      'donor': donorArticles,
    }.entries) {
      for (final article in group.value) {
        id++;
        await db.insert('articles', {
          'id': id,
          'kind': group.key,
          'title': article.title,
          'summary': article.summary,
          'source': article.source,
        });
        for (final section in article.sections.indexed) {
          await db.insert('article_sections', {
            'articleId': id,
            'position': section.$1 + 1,
            'title': section.$2.$1,
            'body': section.$2.$2,
          });
        }
      }
    }
  }

  /// Raw SQL rows for the administrator's table viewer.
  Future<Map<String, dynamic>> inspectTables() =>
      database.transaction((tx) async {
        final result = <String, dynamic>{};
        for (final table in [
          'accounts',
          'events',
          'requests',
          'notices',
          'saved',
          'metadata',
          'categories',
          'locations',
          'articles',
          'article_sections',
        ]) {
          result[table] = await tx.query(table);
        }
        return result;
      });

  Future<Map<String, dynamic>?> load() => database.transaction((tx) async {
    final meta = await tx.query('metadata');
    if (meta.isEmpty) return null;
    final result = <String, dynamic>{};
    for (final table in ['accounts', 'events', 'requests', 'notices']) {
      result[table] =
          (await tx.query(
            table,
            orderBy: table == 'accounts' ? 'email' : 'id',
          )).map((row) {
            final value = Map<String, dynamic>.from(row);
            for (final key in ['blocked', 'published', 'read']) {
              if (value.containsKey(key)) value[key] = value[key] == 1;
            }
            return value;
          }).toList();
    }
    final saved = <String, List<int>>{};
    for (final row in await tx.query('saved')) {
      saved
          .putIfAbsent(row['email'] as String, () => [])
          .add(row['eventId'] as int);
    }
    result['saved'] = saved;
    for (final row in meta) {
      result[row['key'] as String] = row['value'];
    }
    return result;
  });

  Future<void> save(Map<String, dynamic> snapshot) =>
      database.transaction((tx) async {
        for (final table in [
          'saved',
          'notices',
          'requests',
          'events',
          'accounts',
          'metadata',
          'categories',
          'locations',
        ]) {
          await tx.delete(table);
        }
        final batch = tx.batch();
        for (final table in ['accounts', 'events', 'requests', 'notices']) {
          for (final row in snapshot[table] as List) {
            batch.insert(
              table,
              (row as Map<String, dynamic>).map(
                (key, value) =>
                    MapEntry(key, value is bool ? (value ? 1 : 0) : value),
              ),
            );
          }
        }
        (snapshot['saved'] as Map<String, dynamic>).forEach((email, ids) {
          for (final id in ids as List) {
            batch.insert('saved', {'email': email, 'eventId': id});
          }
        });
        for (final key in ['nextRequest', 'nextNotice']) {
          batch.insert('metadata', {'key': key, 'value': snapshot[key]});
        }
        await batch.commit(noResult: true);
        await tx.execute(
          'INSERT INTO categories(name) SELECT DISTINCT category FROM events',
        );
        await tx.execute(
          'INSERT INTO locations(name) SELECT DISTINCT location FROM events',
        );
      });

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
