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
  testWidgets('Mobile event search, joining and cancellation', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.resetForTest();
    store.register('Қатысушы', 'member@example.com', '123456');
    store.login('member@example.com', '123456');
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Шаралар'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Кітап');
    await tester.pumpAndSettle();
    expect(find.text('Кітап жинау акциясы'), findsOneWidget);
    expect(find.text('Қан тапсыру күні'), findsNothing);
    await tester.ensureVisible(find.text('Толығырақ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Толығырақ'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Қатысу'));
    await tester.tap(find.text('Қатысу'));
    await tester.pumpAndSettle();
    expect(store.joinedEvents, contains(3));
    await tester.ensureVisible(find.text('Қатысудан бас тарту'));
    await tester.tap(find.text('Қатысудан бас тарту'));
    await tester.pumpAndSettle();
    expect(store.joinedEvents, isEmpty);
  });
  testWidgets('Desktop navigation and empty profile render', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.resetForTest();
    store.register('Қатысушы', 'profile@example.com', '123456');
    store.login('profile@example.com', '123456');
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Іс-шараларға қатысу'), findsOneWidget);
    await tester.tap(find.text('Жеке кабинет'));
    await tester.pumpAndSettle();
    expect(find.text('Әзірге қатысатын шараңыз жоқ.'), findsOneWidget);
  });
}
