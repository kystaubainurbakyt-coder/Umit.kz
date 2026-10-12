import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../screens/auth/auth_screen.dart';

Future<void> showEventDetails(BuildContext context, CharityEvent event) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => EventDetails(eventId: event.id),
    );

class EventDetails extends StatelessWidget {
  const EventDetails({super.key, required this.eventId});
  final int eventId;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final event = store.eventById(eventId);
      if (event == null)
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Text('Шара жойылған.'),
          ),
        );
      final request = store.requestFor(eventId);
      final cancellable =
          request != null &&
          [
            RequestStatus.pending,
            RequestStatus.approved,
          ].contains(request.status);
      final completed = request?.status == RequestStatus.completed;
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${event.location}\n${event.date}\nБос орын: ${event.capacity - store.occupied(event.id)}',
                  style: const TextStyle(color: muted, height: 1.7),
                ),
                const SizedBox(height: 18),
                Text(event.description, style: const TextStyle(height: 1.7)),
                const SizedBox(height: 18),
                if (request != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Өтінім мәртебесі: ${request.status.label}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if (request.note.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(request.note),
                        ],
                        if ([
                          RequestStatus.approved,
                          RequestStatus.completed,
                        ].contains(request.status)) ...[
                          const SizedBox(height: 12),
                          Text('Қатысу билеті: ${request.ticket}'),
                          TextButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text:
                                      '${request.ticket}\n${event.title}\n${event.date}\n${event.location}',
                                ),
                              );
                              if (context.mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Билет көшірілді'),
                                  ),
                                );
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Билетті көшіру'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                const Text(
                  'Жергілікті демо. Өтінімді осы құрылғыдағы әкімші өңдейді; медициналық ұйымға жазылу жүргізілмейді.',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: completed || (!event.published && !cancellable)
                      ? null
                      : () {
                          if (!store.signedIn) {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const AuthScreen(),
                              ),
                            );
                            return;
                          }
                          try {
                            if (cancellable) {
                              store.cancel(request.id);
                            } else {
                              store.apply(eventId);
                            }
                          } on StateError catch (e) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(e.message)));
                          }
                        },
                  icon: Icon(
                    cancellable || completed ? Icons.check : Icons.add,
                  ),
                  label: Text(
                    completed
                        ? 'Қатысу аяқталған'
                        : !event.published && !cancellable
                        ? 'Өтінім қабылдау жабық'
                        : cancellable
                        ? 'Қатысудан бас тарту'
                        : store.signedIn
                        ? 'Қатысу'
                        : 'Кіріп, өтінім жіберу',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
