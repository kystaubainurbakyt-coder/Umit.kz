import 'dart:async';

import 'package:flutter/material.dart';

import '../../state/app_store.dart';
import '../../data/save_database.dart';

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  String table = 'accounts';
  late Future<Map<String, dynamic>> data;
  bool exporting = false;

  Future<void> download() async {
    setState(() => exporting = true);
    try {
      final bytes = await store.exportDatabase();
      if (!mounted || !store.isAdmin) return;
      final message = await saveDatabaseFile(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Базаны жүктеу мүмкін болмады. Қайта көріңіз.'),
        ),
      );
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  final tables = const {
    'accounts': 'Пайдаланушылар',
    'events': 'Іс-шаралар',
    'requests': 'Өтінімдер',
    'notices': 'Хабарламалар',
    'saved': 'Сақталған шаралар',
    'categories': 'Шара санаттары',
    'locations': 'Өткізу орындары',
    'articles': 'Ақпараттық мақалалар',
    'article_sections': 'Мақала бөлімдері',
    'metadata': 'Жүйелік деректер',
  };

  @override
  void initState() {
    super.initState();
    data = store.databaseSnapshot();
    store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    scheduleMicrotask(() {
      if (!mounted) return;
      setState(() => data = store.databaseSnapshot());
    });
  }

  void _refresh() {
    setState(() => data = store.databaseSnapshot());
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Деректер базасы'),
        actions: [
          IconButton(
            tooltip: 'Жаңарту',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: !store.isAdmin
          ? const Center(child: Text('Бұл бөлім тек әкімшіге қолжетімді.'))
          : FutureBuilder<Map<String, dynamic>>(
              future: data,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Базаны оқу мүмкін болмады. Қосымшаны қайта іске қосып көріңіз.',
                    ),
                  );
                }
                final source = snapshot.data!;
                final rows = (source[table] as List)
                    .map((r) => Map<String, dynamic>.from(r))
                    .toList();
                final columns = rows.isEmpty
                    ? <String>[]
                    : rows.first.keys.toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: FilledButton.icon(
                        onPressed: exporting ? null : download,
                        icon: const Icon(Icons.download),
                        label: Text(
                          exporting ? 'Дайындалуда…' : 'Базаны жүктеу (.db)',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final entry in tables.entries)
                            ChoiceChip(
                              label: Text(entry.value),
                              selected: table == entry.key,
                              onSelected: (_) =>
                                  setState(() => table = entry.key),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$table · ${rows.length} жазба · SQLite'),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: rows.isEmpty
                          ? const Center(
                              child: Text('Бұл кестеде әзірге дерек жоқ.'),
                            )
                          : SingleChildScrollView(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  border: TableBorder.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                  columns: [
                                    for (final column in columns)
                                      DataColumn(label: Text(column)),
                                  ],
                                  rows: [
                                    for (final row in rows)
                                      DataRow(
                                        cells: [
                                          for (final column in columns)
                                            DataCell(
                                              SizedBox(
                                                width:
                                                    column == 'description' ||
                                                        column == 'text'
                                                    ? 300
                                                    : null,
                                                child: SelectableText(
                                                  '${row[column] ?? ''}',
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
    ),
  );
}
