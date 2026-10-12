import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/models.dart';
import '../../state/app_store.dart';

Future<void> editEvent(BuildContext context, [CharityEvent? existing]) =>
    showDialog<void>(
      context: context,
      builder: (_) => EventEditor(event: existing),
    );

class EventEditor extends StatefulWidget {
  const EventEditor({super.key, this.event});
  final CharityEvent? event;
  @override
  State<EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<EventEditor> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.event?.title);
  late final location = TextEditingController(text: widget.event?.location);
  late final description = TextEditingController(
    text: widget.event?.description,
  );
  late final capacity = TextEditingController(
    text: '${widget.event?.capacity ?? 50}',
  );
  late String category = widget.event?.category ?? 'Донорлық';
  late DateTime date =
      widget.event?.scheduledAt ?? DateTime.now().add(const Duration(days: 7));
  late bool published = widget.event?.published ?? true;
  String? error;
  @override
  void dispose() {
    title.dispose();
    location.dispose();
    description.dispose();
    capacity.dispose();
    super.dispose();
  }

  String? requiredText(String? v) =>
      v == null || v.trim().isEmpty ? 'Міндетті өріс' : null;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.event == null ? 'Жаңа іс-шара' : 'Іс-шараны өңдеу'),
    content: SizedBox(
      width: 540,
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const ValueKey('event-title'),
                controller: title,
                decoration: const InputDecoration(labelText: 'Шара атауы'),
                validator: requiredText,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Санат'),
                items: ['Донорлық', 'Еріктілік', 'Қайырымдылық']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const ValueKey('event-location'),
                controller: location,
                decoration: const InputDecoration(
                  labelText: 'Қала және мекенжай',
                ),
                validator: requiredText,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (selected == null || !context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(date),
                  );
                  if (time != null && mounted)
                    setState(
                      () => date = DateTime(
                        selected.year,
                        selected.month,
                        selected.day,
                        time.hour,
                        time.minute,
                      ),
                    );
                },
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  '${date.day}.${date.month}.${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const ValueKey('event-capacity'),
                controller: capacity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Қатысушыларға арналған орын',
                ),
                validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1
                    ? 'Оң бүтін сан енгізіңіз'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const ValueKey('event-description'),
                controller: description,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Толық сипаттама'),
                validator: requiredText,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Жариялау'),
                value: published,
                onChanged: (v) => setState(() => published = v),
              ),
              if (error != null)
                Text(error!, style: const TextStyle(color: red)),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Болдырмау'),
      ),
      FilledButton(
        key: const ValueKey('save-event'),
        onPressed: () {
          if (!form.currentState!.validate()) return;
          try {
            store.saveEvent(
              CharityEvent(
                widget.event?.id ?? store.nextEventId,
                category,
                title.text.trim(),
                location.text.trim(),
                '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                CharityEvent.categoryIcon(category),
                description.text.trim(),
                capacity: int.parse(capacity.text),
                published: published,
                startsAt: date,
              ),
            );
            Navigator.pop(context);
          } on StateError catch (e) {
            setState(() => error = e.message);
          }
        },
        child: const Text('Сақтау'),
      ),
    ],
  );
}
