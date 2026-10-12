import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  setUp(store.resetForTest);
  testWidgets(
    'Login is centered with the original logo above account heading',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const LifeShareApp());
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      final form = find.byType(Form);
      expect(tester.getCenter(form).dx, closeTo(720, 1));
      expect(tester.getCenter(form).dy, closeTo(550, 1));
      expect(
        tester.getBottomLeft(find.byType(AuthLogo)).dy,
        lessThan(tester.getTopLeft(find.text('Жүйеге кіру')).dy),
      );
      expect(find.text('Донорлық және\nқайырымдылық'), findsNothing);
      final logo = tester.widget<Image>(
        find.byKey(const ValueKey('auth-logo')),
      );
      expect(
        (logo.image as AssetImage).assetName,
        'assets/images/umit_emblem.png',
      );
    },
  );

  testWidgets('Information article expands to detailed guidance and source', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    final title = find.text('Қан донорлығы туралы');
    expect(title, findsNothing);
    await tester.scrollUntilVisible(
      title,
      400,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('home-content-0')),
        matching: find.byType(Scrollable),
      ).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(title);
    await tester.pumpAndSettle();
    expect(find.text('Кім өтініш бере алады?'), findsOneWidget);
    expect(find.text('Ақпарат көзі'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
  });
}
