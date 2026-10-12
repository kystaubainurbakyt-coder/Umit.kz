import 'package:flutter/material.dart';

import 'app.dart';
import 'state/app_store.dart';

export 'app.dart';
export 'core/theme.dart';
export 'state/app_store.dart';
export 'screens/home/home_screen.dart';
export 'widgets/brand.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LifeShareApp(startup: store.initialize()));
}
