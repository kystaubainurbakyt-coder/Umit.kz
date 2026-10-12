import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  setUp(store.resetForTest);
  testWidgets('Small portrait phone supports auth and home without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(const LifeShareApp());
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Тіркелмей қарау'));
    await tester.tap(find.text('Тіркелмей қарау'));
    await tester.pumpAndSettle();
    expect(find.text('Іс-шараларға қатысу'), findsOneWidget);
    await tester.ensureVisible(find.text('Қатысу тәртібін қарау'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Қатысу тәртібін қарау'));
    await tester.pumpAndSettle();
    expect(find.text('Донорлыққа қатысу тәртібі'), findsOneWidget);
  });
}
