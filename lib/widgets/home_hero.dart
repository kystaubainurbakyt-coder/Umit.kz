import 'package:flutter/material.dart';

import '../core/theme.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    required this.currentName,
    required this.onNavigate,
  });
  final String currentName;
  final ValueChanged<int> onNavigate;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        currentName == 'Қонақ' ? 'ÜMIT' : 'Қош келдіңіз, $currentName',
        style: const TextStyle(color: muted, fontSize: 14),
      ),
      const SizedBox(height: 6),
      const Text(
        'Іс-шараларға қатысу',
        style: TextStyle(
          fontSize: 32,
          height: 1.15,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 22),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFE73D4C),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ДОНОРЛЫҚ',
                        style: TextStyle(
                          color: Color(0xFFFFE5E7),
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Қан доноры болу',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Қатысу тәртібімен танысып, қалаңыздағы донорлық шараларды қараңыз. Қабылдау уақыты мен талаптарды қан орталығынан нақтылау қажет.',
              style: TextStyle(
                color: Color(0xFFFFF1F2),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFFFF),
                  foregroundColor: const Color(0xFFB42332),
                ),
                onPressed: () => onNavigate(2),
                child: const Text('Қатысу тәртібін қарау'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _quickAction(
              context,
              Icons.event_outlined,
              'Шараларды көру',
              () => onNavigate(1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _quickAction(
              context,
              Icons.bookmark_outline,
              'Сақталғандар',
              () => onNavigate(4),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _quickAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: red),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}
