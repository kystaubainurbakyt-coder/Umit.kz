import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../state/app_store.dart';

class MemberProgress extends StatelessWidget {
  const MemberProgress({super.key});
  @override
  Widget build(BuildContext context) {
    final completed = store.myRequests
        .where((r) => r.status == RequestStatus.completed)
        .length;
    final goal = completed < 3
        ? 3
        : completed < 10
        ? 10
        : ((completed ~/ 10) + 1) * 10;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Менің үлесім',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              completed == 0
                  ? 'Алғашқы расталған қатысуыңыз осы жерде көрсетіледі.'
                  : '$completed шараға қатысуыңызды әкімші растады.',
              style: const TextStyle(color: muted, height: 1.5),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: completed / goal,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 10),
            Text(
              'Келесі белес: $completed / $goal шара',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final badge in [
                  (1, 'Алғашқы үлес'),
                  (3, 'Белсенді қатысушы'),
                  (10, 'Тұрақты ерікті'),
                ])
                  Chip(
                    avatar: Icon(
                      completed >= badge.$1
                          ? Icons.verified_outlined
                          : Icons.lock_outline,
                      size: 18,
                    ),
                    label: Text(badge.$2),
                    backgroundColor: completed >= badge.$1
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Бұл — қосымшадағы қатысу есебі. Медициналық құжат немесе ресми сертификат емес.',
              style: TextStyle(fontSize: 11, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

void showNotifications(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => ListenableBuilder(
      listenable: store,
      builder: (context, _) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.65,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Хабарламалар',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (store.signedIn)
                      TextButton(
                        onPressed: store.markRead,
                        child: const Text('Оқылды'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: store.notices.isEmpty
                    ? const Center(child: Text('Әзірге хабарлама жоқ.'))
                    : ListView(
                        children: [
                          for (final n in store.notices)
                            ListTile(
                              leading: Icon(
                                n.read
                                    ? Icons.mail_outline
                                    : Icons.mark_email_unread_outlined,
                                color: red,
                              ),
                              title: Text(
                                n.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: n.read
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
