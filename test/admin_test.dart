import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/admin/admin_screen.dart';

void main() {
  setUp(store.resetForTest);
  testWidgets('Admin guard denies guests', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminScreen()));
    expect(find.text('Бұл бөлім тек әкімшіге қолжетімді.'), findsOneWidget);
    expect(find.text('Іс-шара қосу'), findsNothing);
  });
  testWidgets('Admin creates an event and members see it', (tester) async {
    tester.view.physicalSize = const Size(1000, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.login(AppStore.adminEmail, AppStore.adminPassword);
    await tester.pumpWidget(const LifeShareApp());
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      MaterialApp(
        theme: portalTheme(Brightness.light),
        home: const AdminScreen(),
      ),
    );
    await tester.tap(find.text('Іс-шара қосу'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('event-title')),
      'Жаңа еріктілер кездесуі',
    );
    await tester.enterText(
      find.byKey(const ValueKey('event-location')),
      'Алматы · Кездесу залы',
    );
    await tester.enterText(
      find.byKey(const ValueKey('event-description')),
      'Еріктілерге арналған таныстыру және міндеттерді бөлу.',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-event')));
    await tester.tap(find.byKey(const ValueKey('save-event')));
    await tester.pumpAndSettle();
    expect(
      store.events.any((e) => e.title == 'Жаңа еріктілер кездесуі'),
      isTrue,
    );
    store.logout();
    await tester.pumpWidget(
      MaterialApp(
        theme: portalTheme(Brightness.light),
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Жаңа еріктілер кездесуі'), findsOneWidget);
  });
}
