// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  setUp(store.resetForTest);
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
  });
  tearDown(() {
    binding.platformDispatcher.clearAccessibilityFeaturesTestValue();
  });
  testWidgets('Registration and password sign-in work', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LifeShareApp());
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('auth-logo')), findsOneWidget);
    await tester.ensureVisible(find.text('Аккаунтыңыз жоқ па? Тіркелу'));
    await tester.tap(find.text('Аккаунтыңыз жоқ па? Тіркелу'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('name-field')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('name-field')), 'Айдана');
    await tester.enterText(
      find.byKey(const ValueKey('email-field')),
      'aidana@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password-field')),
      '123456',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('submit-auth')));
    await tester.tap(find.byKey(const ValueKey('submit-auth')));
    await tester.pumpAndSettle();

    expect(find.text('Тіркелу сәтті өтті. Енді кіріңіз.'), findsOneWidget);
    expect(find.byKey(const ValueKey('name-field')), findsNothing);
    expect(find.text('Алдағы шаралар'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('email-field')),
      'random@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password-field')),
      '654321',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('submit-auth')));
    await tester.tap(find.byKey(const ValueKey('submit-auth')));
    await tester.pumpAndSettle();

    expect(
      find.text('Электрондық пошта немесе құпиясөз қате.'),
      findsOneWidget,
    );
    expect(find.text('Алдағы шаралар'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('email-field')),
      'aidana@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password-field')),
      '123456',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('submit-auth')));
    await tester.tap(find.byKey(const ValueKey('submit-auth')));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Іс-шараларға қатысу'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Қан тапсыру күні'),
      300,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('home-content-0')),
        matching: find.byType(Scrollable),
      ).first,
    );
    expect(find.text('Қан тапсыру күні'), findsOneWidget);
  });
}
