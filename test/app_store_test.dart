import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_application_1/data/local_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/state/app_store.dart';
import 'package:flutter_application_1/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppStore repository;
  sqfliteFfiInit();
  late LocalDatabase database;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = LocalDatabase(
      opener: (options) => databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: options,
      ),
    );
    repository = AppStore(database: database);
  });
  void member() {
    repository.register('Айдана', 'aidana@example.com', 'password1');
    expect(repository.login('aidana@example.com', 'password1'), isNull);
  }

  void admin() {
    expect(
      repository.login(AppStore.adminEmail, AppStore.adminPassword),
      isNull,
    );
  }

  test(
    'Members cannot mutate admin data or grant themselves an admin role',
    () {
      member();
      expect(repository.isAdmin, isFalse);
      expect(() => repository.deleteEvent(1), throwsStateError);
      expect(() => repository.announce('Test'), throwsStateError);
      expect(
        () => repository.setBlocked(AppStore.adminEmail, true),
        throwsStateError,
      );
      expect(() => repository.users, throwsStateError);
      expect(
        repository.register('Fake', AppStore.adminEmail, 'newpassword'),
        isNotNull,
      );
    },
  );
  test(
    'Requests, ticket, completion and notifications follow real role flow',
    () {
      member();
      repository.apply(1);
      expect(() => repository.apply(1), throwsStateError);
      final id = repository.myRequests.single.id;
      expect(repository.myRequests.single.status, RequestStatus.pending);
      admin();
      repository.review(id, RequestStatus.approved, 'Келу уақытын тексеріңіз.');
      repository.review(id, RequestStatus.completed, 'Қатысу расталды');
      expect(
        () => repository.review(id, RequestStatus.approved, ''),
        throwsStateError,
      );
      repository.login('aidana@example.com', 'password1');
      expect(repository.myRequests.single.status, RequestStatus.completed);
      expect(repository.myRequests.single.ticket, 'UMIT-000001');
      expect(repository.notices.length, 3);
      repository.markRead();
      expect(repository.notices.every((n) => n.read), isTrue);
      expect(() => repository.cancel(id), throwsStateError);
    },
  );
  test(
    'Capacity, blocked users, archive, deletion and cancellation are enforced',
    () {
      admin();
      final e = repository.eventById(1)!;
      repository.saveEvent(
        CharityEvent(
          e.id,
          e.category,
          e.title,
          e.location,
          e.date,
          e.icon,
          e.description,
          capacity: 1,
        ),
      );
      member();
      repository.apply(1);
      final first = repository.myRequests.single.id;
      repository.register('Екінші', 'second@example.com', 'password2');
      repository.login('second@example.com', 'password2');
      repository.apply(1);
      final second = repository.myRequests.single.id;
      admin();
      repository.review(first, RequestStatus.approved, '');
      expect(
        () => repository.review(second, RequestStatus.approved, ''),
        throwsStateError,
      );
      expect(() => repository.deleteEvent(1), throwsStateError);
      repository.setBlocked('second@example.com', true);
      expect(
        repository.login('second@example.com', 'password2'),
        contains('бұғатталған'),
      );
      repository.saveEvent(repository.eventById(1)!.withPublished(false));
      expect(repository.events.any((e) => e.id == 1), isFalse);
      repository.login('aidana@example.com', 'password1');
      repository.cancel(first);
      expect(repository.joinedEvents, isEmpty);
      expect(() => repository.apply(1), throwsStateError);
    },
  );
  test('Saved events and admin changes survive repository reload with no auto-login', () async {
    await repository.initialize();
    expect(repository.storageError, isNull);
    member();
    repository.toggleSaved(2);
    repository.apply(3);
    admin();
    repository.review(
      repository.requests.single.id,
      RequestStatus.approved,
      'Расталды',
    );
    repository.announce('Кесте жаңартылды');
    await repository.flush();
    final reloaded = AppStore(database: database);
    await reloaded.initialize();
    expect(reloaded.signedIn, isFalse);
    expect(reloaded.login('aidana@example.com', 'password1'), isNull);
    expect(reloaded.savedEvents, contains(2));
    expect(reloaded.myRequests.single.status, RequestStatus.approved);
    expect(reloaded.notices.first.text, 'Кесте жаңартылды');
    expect(reloaded.storageError, isNull);
    await reloaded.closeStorage();
  });
  test('SQLite file reopens and stores salted hashes, not passwords', () async {
    final directory = await Directory.systemTemp.createTemp(
      'umit_sqlite_test_',
    );
    final path = '${directory.path}/umit.db';
    LocalDatabase createDatabase() => LocalDatabase(
      opener: (options) =>
          databaseFactoryFfi.openDatabase(path, options: options),
    );
    final firstDb = createDatabase();
    final first = AppStore(database: firstDb);
    await first.initialize();
    expect(first.storageError, isNull);
    first.register('Member', 'persist@example.com', 'secret123');
    first.login('persist@example.com', 'secret123');
    first.apply(1);
    first.toggleSaved(2);
    await first.flush();
    final row = (await firstDb.database.query(
      'accounts',
      where: 'email = ?',
      whereArgs: ['persist@example.com'],
    )).single;
    expect(row['hash'], isNot('secret123'));
    expect(row['salt'], isNotEmpty);
    final snapshot = await firstDb.load();
    final invalid = jsonDecode(jsonEncode(snapshot)) as Map<String, dynamic>;
    invalid['requests'][0]['eventId'] = -1;
    await expectLater(firstDb.save(invalid), throwsA(isA<DatabaseException>()));
    expect(await firstDb.load(), equals(snapshot));
    // Simulate the existing version-1 database before the four new tables.
    for (final table in [
      'article_sections',
      'articles',
      'categories',
      'locations',
    ]) {
      await firstDb.database.execute('DROP TABLE $table');
    }
    await firstDb.database.setVersion(1);
    await first.closeStorage();
    final reopened = AppStore(database: createDatabase());
    await reopened.initialize();
    expect(reopened.storageError, isNull);
    expect(reopened.signedIn, isFalse);
    expect(reopened.login('persist@example.com', 'wrong'), isNotNull);
    expect(reopened.login('persist@example.com', 'secret123'), isNull);
    expect(reopened.myRequests.single.eventId, 1);
    expect(reopened.savedEvents, contains(2));
    await expectLater(reopened.databaseSnapshot(), throwsStateError);
    await expectLater(reopened.exportDatabase(), throwsStateError);
    reopened.login(AppStore.adminEmail, AppStore.adminPassword);
    final inspected = await reopened.databaseSnapshot();
    expect(inspected, hasLength(10));
    expect(inspected['accounts'], hasLength(2));
    expect(inspected['categories'], isNotEmpty);
    expect(inspected['locations'], isNotEmpty);
    expect(inspected['articles'], isNotEmpty);
    expect(inspected['article_sections'], isNotEmpty);
    expect(inspected['saved'], hasLength(1));
    final tableNames = await reopened.databaseSnapshot();
    expect(
      tableNames.keys,
      containsAll(['metadata', 'articles', 'article_sections']),
    );
    final bytes = await reopened.exportDatabase();
    expect(ascii.decode(bytes.take(16).toList()), 'SQLite format 3\u0000');
    final exportedPath = '${directory.path}/exported.db';
    await File(exportedPath).writeAsBytes(bytes);
    final exported = await databaseFactoryFfi.openDatabase(exportedPath);
    expect(
      (await exported.rawQuery('PRAGMA integrity_check')).single.values.single,
      'ok',
    );
    final exportedTables = await exported.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
    );
    expect(exportedTables, hasLength(10));
    expect(await exported.query('requests'), hasLength(1));
    expect(await exported.query('article_sections'), isNotEmpty);
    expect(
      (await exported.query(
        'accounts',
        where: 'email = ?',
        whereArgs: ['persist@example.com'],
      )).single['hash'],
      row['hash'],
    );
    expect(await exported.getVersion(), 2);
    await exported.close();
    await reopened.closeStorage();
    // Delete only the files this test created, without recursive removal.
    for (final entity in await directory.list().toList()) {
      await entity.delete();
    }
    await directory.delete();
  });

  test(
    'SharedPreferences migrate into SQLite without losing requests',
    () async {
      await repository.initialize();
      member();
      repository.apply(1);
      await repository.flush();
      final snapshot = await database.load();
      await repository.closeStorage();
      SharedPreferences.setMockInitialValues({
        AppStore.storageKey: jsonEncode(snapshot),
      });
      final migrated = AppStore(database: database);
      await migrated.initialize();
      expect(migrated.storageError, isNull);
      expect(migrated.login('aidana@example.com', 'password1'), isNull);
      expect(migrated.myRequests.single.eventId, 1);
      expect(
        (await SharedPreferences.getInstance()).getString(AppStore.storageKey),
        isNull,
      );
      await migrated.closeStorage();
    },
  );
  test('Only request owner can cancel; rejection requires a reason', () {
    member();
    repository.apply(1);
    final id = repository.myRequests.single.id;
    repository.register('Басқа', 'other@example.com', 'password2');
    repository.login('other@example.com', 'password2');
    expect(() => repository.cancel(id), throwsStateError);
    admin();
    expect(
      () => repository.review(id, RequestStatus.rejected, ''),
      throwsStateError,
    );
    repository.review(id, RequestStatus.rejected, 'Уақыт келісілмеді');
    repository.login('aidana@example.com', 'password1');
    expect(repository.joinedEvents, isEmpty);
    repository.apply(1);
    expect(repository.myRequests.length, 2);
  });
}
