import 'package:flutter/material.dart';

import '../core/theme.dart';

class Brand extends StatelessWidget {
  const Brand({super.key, this.light = false});
  final bool light;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/images/umit_emblem.png',
        width: 42,
        height: 46,
        semanticLabel: 'ÜMIT логотипі',
      ),
      const SizedBox(width: 10),
      Flexible(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'ÜMIT',
            style: TextStyle(
              fontSize: 24,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
              color: light
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    ],
  );
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/images/umit_emblem.png',
        key: const ValueKey('auth-logo'),
        width: 132,
        height: 142,
        fit: BoxFit.contain,
        semanticLabel: 'ÜMIT логотипі',
      ),
      const SizedBox(height: 10),
      const Text(
        'ÜMIT',
        style: TextStyle(
          fontSize: 30,
          color: red,
          fontWeight: FontWeight.w700,
          letterSpacing: 4,
        ),
      ),
    ],
  );
}
