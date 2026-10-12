import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/app_store.dart';
import '../../widgets/brand.dart';
import '../auth/auth_screen.dart';
import '../home/home_screen.dart';
import 'event_editor.dart';
import 'database_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int tab = 0;
  String query = '';
  RequestStatus? filter;
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void act(VoidCallback action) {
    try {
      action();
    } on StateError catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> confirm(String message, VoidCallback action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Әрекетті растау'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Болдырмау'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Растау'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) act(action);
  }

  Future<void> review(Participation request, RequestStatus next) async {
    final controller = TextEditingController();
    String? error;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, refresh) => AlertDialog(
          title: Text(next.label),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: next == RequestStatus.rejected
                  ? 'Бас тарту себебі'
                  : 'Қатысушыға түсініктеме',
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Болдырмау'),
            ),
            FilledButton(
              onPressed: () {
                try {
                  store.review(request.id, next, controller.text);
                  Navigator.pop(ctx);
                } on StateError catch (e) {
                  refresh(() => error = e.message);
                }
              },
              child: const Text('Растау'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> announce() async {
    final controller = TextEditingController();
    String? error;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, refresh) => AlertDialog(
          title: const Text('Қатысушыларға хабарлама'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(labelText: 'Мәтін', errorText: error),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Болдырмау'),
            ),
            FilledButton(
              onPressed: () {
                try {
                  store.announce(controller.text);
                  Navigator.pop(ctx);
                } on StateError catch (e) {
                  refresh(() => error = e.message);
                }
              },
              child: const Text('Жіберу'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  Widget card(Widget child) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(padding: const EdgeInsets.all(18), child: child),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      if (!store.isAdmin)
        return Scaffold(
          appBar: AppBar(title: const Text('Әкімші панелі')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Бұл бөлім тек әкімшіге қолжетімді.'),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
                  ),
                  child: const Text('Жүйеге кіру'),
                ),
              ],
            ),
          ),
        );
      return Scaffold(
        appBar: AppBar(
          title: const Brand(),
          actions: [
            IconButton(
              tooltip: 'Қолданбаны қарау',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
              ),
              icon: const Icon(Icons.open_in_new),
            ),
            IconButton(
              tooltip: 'Аккаунттан шығу',
              onPressed: () {
                store.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Әкімші панелі',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Іс-шаралар, өтінімдер және қатысушыларды басқару',
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Жергілікті демо: өзгерістер осы құрылғыда сақталады.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                if (store.storageError != null)
                  Text(store.storageError!, style: const TextStyle(color: red)),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.table_chart_outlined),
                    label: const Text('Деректер базасын кесте түрінде ашу'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DatabaseScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final item in [
                        'Шолу',
                        'Шаралар',
                        'Өтінімдер',
                        'Пайдаланушылар',
                      ].indexed)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(item.$2),
                            selected: tab == item.$1,
                            onSelected: (_) => setState(() {
                              tab = item.$1;
                              query = '';
                              search.clear();
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (tab != 0) ...[
                  TextField(
                    controller: search,
                    onChanged: (v) => setState(() => query = v.toLowerCase()),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Іздеу',
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                if (tab == 0) ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final stat in [
                        ('Жарияланған шара', store.events.length),
                        (
                          'Қаралудағы өтінім',
                          store.requests
                              .where((r) => r.status == RequestStatus.pending)
                              .length,
                        ),
                        (
                          'Пайдаланушы',
                          store.users
                              .where((u) => u.role == UserRole.member)
                              .length,
                        ),
                        (
                          'Қатысу аяқталды',
                          store.requests
                              .where((r) => r.status == RequestStatus.completed)
                              .length,
                        ),
                      ])
                        SizedBox(
                          width: 225,
                          child: card(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${stat.$2}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(stat.$1),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => editEvent(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Іс-шара қосу'),
                      ),
                      OutlinedButton.icon(
                        onPressed: announce,
                        icon: const Icon(Icons.campaign_outlined),
                        label: const Text('Хабарлама жіберу'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          String cell(String text) {
                            if (RegExp(r'^[=+@-]').hasMatch(text))
                              text = "'$text";
                            return '"${text.replaceAll('"', '""')}"';
                          }

                          final rows = [
                            'Аты-жөні,Пошта,Шара,Мәртебе',
                            for (final r in store.requests)
                              [
                                store.memberName(r.email),
                                r.email,
                                store.eventById(r.eventId)?.title ?? '',
                                r.status.label,
                              ].map(cell).join(','),
                          ];
                          await Clipboard.setData(
                            ClipboardData(text: rows.join('\n')),
                          );
                          if (context.mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('CSV есебі көшірілді'),
                              ),
                            );
                        },
                        child: const Text('Есепті көшіру (CSV)'),
                      ),
                    ],
                  ),
                ],
                if (tab == 1) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      key: const ValueKey('admin-add-event'),
                      onPressed: () => editEvent(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Іс-шара қосу'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (final e in store.allEvents.where(
                    (e) => '${e.title} ${e.location}'.toLowerCase().contains(
                      query,
                    ),
                  ))
                    card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${e.date}\n${e.location}\nОрын: ${store.occupied(e.id)} / ${e.capacity}',
                            style: const TextStyle(height: 1.6),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              e.published ? 'Жарияланған' : 'Жарияланбаған',
                            ),
                            value: e.published,
                            onChanged: (v) =>
                                act(() => store.saveEvent(e.withPublished(v))),
                          ),
                          Wrap(
                            spacing: 12,
                            children: [
                              TextButton.icon(
                                onPressed: () => editEvent(context, e),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Өңдеу'),
                              ),
                              TextButton.icon(
                                onPressed: () => confirm(
                                  '«${e.title}» шарасын өшіру керек пе? Өтінімі бар шаралар тек жариялаудан алынады.',
                                  () => store.deleteEvent(e.id),
                                ),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Өшіру'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
                if (tab == 2) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Барлығы'),
                        selected: filter == null,
                        onSelected: (_) => setState(() => filter = null),
                      ),
                      for (final status in RequestStatus.values)
                        ChoiceChip(
                          label: Text(status.label),
                          selected: filter == status,
                          onSelected: (_) => setState(() => filter = status),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (store.requests.isEmpty)
                    const Text(
                      'Әзірге өтінім жоқ. Пайдаланушы шараға қатысу өтінімін жібергенде осы жерде көрінеді.',
                    ),
                  for (final r in store.requests.reversed.where(
                    (r) =>
                        (filter == null || r.status == filter) &&
                        '${r.email} ${store.memberName(r.email)} ${store.eventById(r.eventId)?.title}'
                            .toLowerCase()
                            .contains(query),
                  ))
                    card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.eventById(r.eventId)?.title ?? 'Шара',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${store.memberName(r.email)}\n${r.email}\n${r.ticket} · ${r.status.label}',
                            style: const TextStyle(height: 1.6),
                          ),
                          if (r.note.isNotEmpty) Text(r.note),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (r.status == RequestStatus.pending)
                                FilledButton(
                                  onPressed: () =>
                                      review(r, RequestStatus.approved),
                                  child: const Text('Мақұлдау'),
                                ),
                              if (r.status == RequestStatus.approved)
                                FilledButton(
                                  onPressed: () =>
                                      review(r, RequestStatus.completed),
                                  child: const Text('Қатысқанын белгілеу'),
                                ),
                              if ([
                                RequestStatus.pending,
                                RequestStatus.approved,
                              ].contains(r.status))
                                OutlinedButton(
                                  onPressed: () =>
                                      review(r, RequestStatus.rejected),
                                  child: const Text('Қабылдамау'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
                if (tab == 3) ...[
                  for (final u in store.users.where(
                    (u) => '${u.name} ${u.email}'.toLowerCase().contains(query),
                  ))
                    card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(u.email),
                          Text(
                            u.role == UserRole.admin
                                ? 'Әкімші'
                                : u.blocked
                                ? 'Бұғатталған'
                                : 'Пайдаланушы',
                          ),
                          if (u.role != UserRole.admin)
                            TextButton(
                              onPressed: () => confirm(
                                u.blocked ? 'Аккаунтты қайта ашу керек пе?' : 'Осы пайдаланушының жүйеге кіруін бұғаттау керек пе?',
                                () => store.setBlocked(u.email, !u.blocked),
                              ),
                              child: Text(
                                u.blocked ? 'Бұғаттан шығару' : 'Бұғаттау',
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
