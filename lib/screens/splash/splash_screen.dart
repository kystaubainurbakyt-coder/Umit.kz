import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/brand.dart';
import '../auth/auth_screen.dart';

/// Shows the brand while local data loads; never keeps a disposed route alive.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.startup});
  final Future<void>? startup;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _minimumElapsed = false;
  bool _ready = false;
  bool _navigated = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      _minimumElapsed = true;
      _continue();
    });
    (widget.startup ?? Future<void>.value()).then(
      (_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _continue();
      },
      onError: (Object error, StackTrace stack) {
        if (mounted) setState(() => _failed = true);
      },
    );
  }

  void _continue() {
    if (!mounted || !_ready || !_minimumElapsed || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AuthLogo(),
                const SizedBox(height: 24),
                const Text(
                  'Донорлық және қайырымдылық',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, height: 1.5),
                ),
                const SizedBox(height: 28),
                if (!_failed)
                  LinearProgressIndicator(
                    value: _ready ? 1 : null,
                    minHeight: 3,
                    semanticsLabel: 'Қосымша жүктелуде',
                  ),
                const SizedBox(height: 14),
                Text(
                  _failed
                      ? 'Деректерді жүктеу мүмкін болмады. Қосымшаны қайта іске қосыңыз.'
                      : 'Қосымша іске қосылуда',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
