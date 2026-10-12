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
  testWidgets('Desktop menu collapses, opens and saved events can be removed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    final menu = find.byKey(const ValueKey('desktop-menu'));
    expect(tester.getSize(menu).width, 260);
    await tester.tap(find.byKey(const ValueKey('toggle-menu')));
    await tester.pumpAndSettle();
    expect(tester.getSize(menu).width, 0);
    await tester.tap(find.byKey(const ValueKey('toggle-menu')));
    await tester.pumpAndSettle();
    expect(tester.getSize(menu).width, 260);
    await tester.tap(find.text('Іс-шаралар'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сақталғандар').first);
    await tester.pumpAndSettle();
    expect(find.text('Қан тапсыру күні'), findsOneWidget);
    expect(find.text('Кітап жинау акциясы'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('save-1')));
    await tester.pumpAndSettle();
    expect(find.text('Әзірге сақталған шара жоқ.'), findsOneWidget);
  });

  testWidgets('Mobile drawer closes after navigation and filters by city', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.byKey(const ValueKey('toggle-menu')));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
      isTrue,
    );
    await tester.tap(find.text('Іс-шаралар'));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
      isFalse,
    );
    await tester.tap(find.text('Барлық қалалар'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Астана').last);
    await tester.pumpAndSettle();
    expect(find.text('Қамқорлық жәрмеңкесі'), findsOneWidget);
    expect(find.text('Қан тапсыру күні'), findsNothing);
    await tester.tap(find.text('Сақталған'));
    await tester.pumpAndSettle();
    expect(find.text('Әзірге сақталған шара жоқ.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('toggle-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('close-menu')));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
      isFalse,
    );
  });

  testWidgets('Theme switch and FAQ work from the menu', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => darkMode.value = false);
    await tester.pumpWidget(const LifeShareApp());
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Тіркелмей қарау'));
    await tester.tap(find.text('Тіркелмей қарау'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(HomeScreen))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.text('Жиі қойылатын сұрақтар'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Шараға қалай қатысамын?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Өтінім жеке кабинетте көрсетіледі.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Түсінікті'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
