import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:myfitnesstale/my_app.dart';
import 'package:myfitnesstale/src/models/db.dart';
import 'package:myfitnesstale/src/utilities/app_router.dart';

final class DeviceTestHarness {
  GoRouter? _router;

  GoRouter get router => _router!;

  Future<void> launchFresh(WidgetTester tester) async {
    await _disposeWidgetTree(tester);
    await DatabaseHelper().deleteForTesting();
    await DatabaseHelper().initialize();
    await _launch(tester);
  }

  Future<void> restartPreservingData(WidgetTester tester) async {
    await _disposeWidgetTree(tester);
    await DatabaseHelper().resetForTesting();
    await DatabaseHelper().initialize();
    await _launch(tester);
  }

  Future<void> dispose(WidgetTester tester) async {
    await _disposeWidgetTree(tester);
    await DatabaseHelper().resetForTesting();
  }

  Future<void> onboard(
    WidgetTester tester, {
    required String name,
    required bool preloadWorkouts,
  }) async {
    await pumpUntilFound(tester, find.text('Welcome'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      name,
    );

    final checkboxFinder =
        find.byKey(const ValueKey('onboarding-preload-workouts'));
    final checkbox = tester.widget<CheckboxListTile>(checkboxFinder);
    if (checkbox.value != preloadWorkouts) {
      await tester.ensureVisible(checkboxFinder);
      await tester.tap(checkboxFinder);
      await tester.pump();
    }

    final submit = find.byKey(const ValueKey('onboarding-submit'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await pumpUntilAbsent(
      tester,
      find.text('Welcome'),
      timeout: const Duration(minutes: 2),
    );
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('main-bottom-navigation')),
      timeout: const Duration(minutes: 2),
    );
  }

  Future<void> tapAndWait(
    WidgetTester tester, {
    required Finder control,
    required Finder destination,
  }) async {
    await tester.ensureVisible(control);
    await tester.tap(control);
    await pumpUntilFound(tester, destination);
    expect(find.textContaining('Not Found'), findsNothing);
  }

  Future<void> goAndWait(
    WidgetTester tester, {
    required String location,
    required Finder destination,
  }) async {
    router.go(location);
    await pumpUntilFound(tester, destination);
    expect(find.textContaining('Not Found'), findsNothing);
  }

  Future<void> selectBottomNavigation(
    WidgetTester tester,
    String label,
  ) async {
    const indices = {
      'Home': 0,
      'Plans': 1,
      'Activity': 2,
      'Profile': 3,
    };
    final index = indices[label];
    if (index == null) {
      throw ArgumentError.value(label, 'label', 'Unknown bottom destination');
    }

    final navigation = find.byKey(const ValueKey('main-bottom-navigation'));
    expect(navigation, findsOneWidget);
    final rect = tester.getRect(navigation);
    await tester.tapAt(Offset(
      rect.left + (rect.width * (index + 0.5) / indices.length),
      rect.center.dy,
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<BottomNavigationBar>(navigation).currentIndex,
      index,
    );
  }

  Future<void> pageBack(WidgetTester tester, Finder destination) async {
    final backButton = find.byIcon(Icons.arrow_back_ios);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await pumpUntilAbsent(tester, backButton);
    await pumpUntilFound(tester, destination);
  }

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    if (finder.evaluate().isEmpty) {
      throw TestFailure(
        'Timed out waiting for ${finder.describeMatch(Plurality.one)}',
      );
    }
    // Cupertino transitions remain mounted longer than Material transitions.
    // Wait until the incoming route is fully interactive before continuing.
    await tester.pump(const Duration(milliseconds: 450));
  }

  Future<void> pumpUntilAbsent(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (finder.evaluate().isNotEmpty && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    if (finder.evaluate().isNotEmpty) {
      throw TestFailure(
        'Timed out waiting for ${finder.describeMatch(Plurality.one)} to disappear',
      );
    }
    await tester.pump(const Duration(milliseconds: 450));
  }

  Future<void> _launch(WidgetTester tester) async {
    _router = AppRouter.createRouter();
    await tester.pumpWidget(MyApp(routerConfig: _router));
    await tester.pump();
  }

  Future<void> _disposeWidgetTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    _router?.dispose();
    _router = null;
  }
}
