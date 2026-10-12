import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../state/app_store.dart';
import '../screens/admin/admin_screen.dart';
import 'brand.dart';
import 'member_progress.dart';

class AppNavigation extends StatelessWidget {
  const AppNavigation({super.key, required this.page, required this.onNavigate, required this.onClose, this.drawer = false});
  final int page;
  final bool drawer;
  final ValueChanged<int> onNavigate;
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              const Expanded(child: Brand()),
              IconButton(
                key: const ValueKey('close-menu'),
                tooltip: 'Мәзірді жабу',
                onPressed: () {
                  onClose();
                },
                icon: const Icon(Icons.close, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Донорлық және қайырымдылық',
            style: TextStyle(color: muted, fontSize: 11),
          ),
          const SizedBox(height: 30),
          for (final item in [
            (Icons.grid_view_rounded, 'Басты бет'),
            (Icons.event_outlined, 'Іс-шаралар'),
            (Icons.bloodtype_outlined, 'Донор болу'),
            (Icons.person_outline, 'Жеке кабинет'),
            (Icons.bookmark_outline, 'Сақталғандар'),
          ].indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                selected: page == item.$1,
                selectedTileColor: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                leading: Icon(item.$2.$1),
                title: Text(item.$2.$2, style: const TextStyle(fontSize: 13)),
                onTap: () {
                  onNavigate(item.$1);
                  if (drawer) onClose();
                },
              ),
            ),
          if (store.isAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Әкімші панелі'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AdminScreen()),
              ),
            ),
          ListTile(
            leading: Badge(
              isLabelVisible: store.notices.any((n) => !n.read),
              child: const Icon(Icons.notifications_outlined),
            ),
            title: const Text('Хабарламалар'),
            onTap: () {
              if (drawer) onClose();
              showNotifications(context);
            },
          ),
          const Divider(height: 35),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Түнгі режим', style: TextStyle(fontSize: 13)),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: darkMode.value,
            onChanged: (value) => darkMode.value = value,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.help_outline),
            title: const Text(
              'Жиі қойылатын сұрақтар',
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              if (drawer) onClose();
              showFaq(context);
            },
          ),
          const SizedBox(height: 25),
          const Text('ÜMIT', style: TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    ),
  );

  void showFaq(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Сұрақтарға жауап'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in [
                (
                  'Шараға қалай қатысамын?',
                  'Шараның сипаттамасын ашып, «Қатысу» батырмасын басыңыз. Өтінім жеке кабинетте көрсетіледі. Осы құрылғыдағы әкімші оның мәртебесін өзгерте алады. Нақты ұйымға өтінім жіберілмейді.',
                ),
                (
                  'Шараны қалай сақтаймын?',
                  'Шара картасындағы бетбелгіні басыңыз. Сақталған шаралар мәзірдегі «Сақталғандар» бөлімінде жиналады.',
                ),
                (
                  'Қатысудан бас тарта аламын ба?',
                  'Жеке кабинеттегі шараны ашып, «Қатысудан бас тарту» батырмасын басыңыз.',
                ),
                (
                  'Деректер сақтала ма?',
                  'Аккаунт, өтінімдер және сақталған шаралар құрылғыда сақталады. Жүйеден шыққанда олар жойылмайды. Деректер басқа құрылғылармен синхрондалмайды.',
                ),
              ])
                ExpansionTile(
                  title: Text(item.$1),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(item.$2),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Түсінікті'),
        ),
      ],
    ),
  );

}
