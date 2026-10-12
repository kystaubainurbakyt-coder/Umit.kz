import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import 'event_details.dart';

class EventList extends StatefulWidget {
  const EventList({
    super.key,
    required this.page,
    required this.city,
    required this.category,
    required this.query,
    required this.newestFirst,
    required this.onNavigate,
  });
  final int page;
  final String city, category, query;
  final bool newestFirst;
  final ValueChanged<int> onNavigate;
  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    final city = widget.city;
    final category = widget.category;
    final query = widget.query;
    final newestFirst = widget.newestFirst;
    final events = store.events;
    final savedEvents = store.savedEvents;
    final joinedEvents = store.joinedEvents;
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final candidates = page == 3
        ? store.myRequests
              .map((r) => store.eventById(r.eventId))
              .whereType<CharityEvent>()
              .toSet()
              .toList()
        : events;
    final visible = candidates
        .where(
          (e) =>
              (page != 3 || store.requestFor(e.id) != null) &&
              (page != 4 || savedEvents.contains(e.id)) &&
              (city == 'Барлық қалалар' || e.location.startsWith(city)) &&
              (page != 2 || e.category == 'Донорлық') &&
              (category == 'Барлығы' || category == e.category) &&
              '${e.title} ${e.location}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    if (newestFirst)
      visible.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    if (visible.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.event_busy_outlined, color: muted, size: 38),
            const SizedBox(height: 12),
            Text(
              page == 4
                  ? 'Әзірге сақталған шара жоқ.'
                  : page == 3
                  ? 'Әзірге қатысатын шараңыз жоқ.'
                  : 'Іздеу бойынша шара табылмады.',
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => widget.onNavigate(1),
              child: const Text('Барлық шараларды көру'),
            ),
          ],
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, box) => Wrap(
        spacing: 18,
        runSpacing: 18,
        children: [
          for (final event in visible)
            SizedBox(
              width: box.maxWidth >= 1000
                  ? (box.maxWidth - 36) / 3
                  : box.maxWidth >= 620
                  ? (box.maxWidth - 18) / 2
                  : box.maxWidth,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF243B43)
                            : const Color(0xFFEDF5F6),
                      ),
                      child: Row(
                        children: [
                          Icon(event.icon, color: red, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              event.category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            key: ValueKey('save-${event.id}'),
                            tooltip: savedEvents.contains(event.id)
                                ? 'Сақталғаннан алып тастау'
                                : 'Шараны сақтау',
                            onPressed: () => setState(() {
                              store.toggleSaved(event.id);
                            }),
                            icon: Icon(
                              savedEvents.contains(event.id)
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              size: 21,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.date,
                            style: const TextStyle(
                              color: red,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 15,
                                color: muted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => showEventDetails(context, event),
                              child: Text(
                                joinedEvents.contains(event.id)
                                    ? (store
                                              .requestFor(event.id)
                                              ?.status
                                              .label ??
                                          'Толығырақ')
                                    : 'Толығырақ',
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
        ],
      ),
    );
  }
}
