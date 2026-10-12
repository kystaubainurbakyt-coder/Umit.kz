import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'screens/splash/splash_screen.dart';

class LifeShareApp extends StatelessWidget {
  const LifeShareApp({super.key, this.startup});
  final Future<void>? startup;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: darkMode,
    builder: (context, dark, _) => MaterialApp(
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: portalTheme(Brightness.dark),
      theme: portalTheme(Brightness.light),
      title: 'ÜMIT — Донорлық және қайырымдылық',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(startup: startup),
    ),
  );
}
