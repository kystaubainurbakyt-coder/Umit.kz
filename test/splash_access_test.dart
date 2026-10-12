import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/splash/splash_screen.dart';
import 'package:flutter_application_1/screens/auth/auth_screen.dart';

void main() {
  setUp(store.resetForTest);

  testWidgets(
    'Splash displays branding, waits for initialization and replaces itself',
    (tester) async {
      final initialization = Completer<void>();
      await tester.pumpWidget(LifeShareApp(startup: initialization.future));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('ÜMIT'), findsOneWidget);
      expect(find.byType(AuthScreen), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(SplashScreen), findsOneWidget);
      initialization.complete();
      await tester.pumpAndSettle();
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(
        Navigator.of(tester.element(find.byType(AuthScreen))).canPop(),
        isFalse,
      );
    },
  );

  testWidgets(
    'Disposing Splash cancels transition and ignores late completion',
    (tester) async {
      final initialization = Completer<void>();
      await tester.pumpWidget(LifeShareApp(startup: initialization.future));
      await tester.pumpWidget(const SizedBox());
      initialization.complete();
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Guest profile entry points request login', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: portalTheme(Brightness.light),
        home: const HomeScreen(),
      ),
    );
    await tester.tap(find.text('Кабинет'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Менің үлесім'), findsNothing);
    Navigator.of(tester.element(find.byType(AuthScreen))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Жеке кабинет'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(AuthScreen))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('toggle-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Жеке кабинет'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Менің үлесім'), findsNothing);
  });

  testWidgets(
    'Login returns to requested profile, logout removes protected navigation history',
    (tester) async {
      store.register('Айдана', 'profile@example.com', 'password1');
      await tester.pumpWidget(
        MaterialApp(
          theme: portalTheme(Brightness.light),
          home: const HomeScreen(initialPage: 3),
        ),
      );
      expect(find.byType(AuthScreen), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('email-field')),
        'profile@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('password-field')),
        'password1',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('submit-auth')));
      await tester.tap(find.byKey(const ValueKey('submit-auth')));
      await tester.pumpAndSettle();
      expect(find.text('profile@example.com'), findsOneWidget);
      expect(find.text('Менің үлесім'), findsOneWidget);
      await tester.tap(find.byTooltip('Аккаунттан шығу'));
      await tester.pumpAndSettle();
      expect(store.signedIn, isFalse);
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('profile@example.com'), findsNothing);
      expect(
        Navigator.of(tester.element(find.byType(AuthScreen))).canPop(),
        isFalse,
      );
    },
  );

  testWidgets(
    'Ending session while profile is visible immediately hides private content',
    (tester) async {
      store.register('Айдана', 'profile@example.com', 'password1');
      store.login('profile@example.com', 'password1');
      await tester.pumpWidget(
        MaterialApp(
          theme: portalTheme(Brightness.light),
          home: const HomeScreen(initialPage: 3),
        ),
      );
      expect(find.text('profile@example.com'), findsOneWidget);
      store.logout();
      await tester.pumpAndSettle();
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('profile@example.com'), findsNothing);
      expect(find.text('Менің үлесім'), findsNothing);
    },
  );
}
