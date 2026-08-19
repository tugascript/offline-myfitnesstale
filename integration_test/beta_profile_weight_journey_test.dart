import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/models/db.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/weight_goal_model.dart';
import 'package:myfitnesstale/src/models/weight_record_model.dart';

import 'support/device_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final harness = DeviceTestHarness();

  testWidgets(
    'persists profile, units, theme, and reminder preferences after restart',
    (tester) async {
      addTearDown(() => harness.dispose(tester));
      await harness.launchFresh(tester);
      await harness.onboard(
        tester,
        name: 'Settings Journey',
        preloadWorkouts: false,
      );

      await harness.selectBottomNavigation(tester, 'Profile');
      await harness.tapAndWait(
        tester,
        control: find.byKey(const ValueKey('profile-edit')),
        destination: find.text('Edit Profile'),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Updated Settings Journey',
      );
      await tester.tap(find.text('Save'));
      await harness.pumpUntilFound(
        tester,
        find.text('Updated Settings Journey'),
      );

      final settings = find.byKey(const ValueKey('profile-app-settings'));
      await tester.ensureVisible(settings);
      await tester.tap(settings);
      await tester.pump(const Duration(milliseconds: 300));

      await _chooseDropdownValue<Units>(
        tester,
        containerKey: const ValueKey('profile-units-selector'),
        label: 'IMPERIAL',
      );
      await _chooseDropdownValue<ThemeType>(
        tester,
        containerKey: const ValueKey('profile-theme-selector'),
        label: 'DARK',
      );

      await harness.selectBottomNavigation(tester, 'Home');
      await harness.tapAndWait(
        tester,
        control: find.byKey(const ValueKey('quick-action-reminders')),
        destination: find.textContaining('Reminder Preferences'),
      );
      await _setSwitch(tester, const ValueKey('reminder-workouts'), true);
      await _setSwitch(
        tester,
        const ValueKey('reminder-weight-records'),
        true,
      );

      await harness.restartPreservingData(tester);
      await harness.pumpUntilFound(
        tester,
        find.byKey(const ValueKey('main-bottom-navigation')),
      );
      await harness.selectBottomNavigation(tester, 'Profile');
      await harness.pumpUntilFound(
        tester,
        find.text('Updated Settings Journey'),
      );
      await harness.pumpUntilFound(
        tester,
        find.textContaining('imperial units • dark theme'),
      );

      await harness.selectBottomNavigation(tester, 'Home');
      await harness.tapAndWait(
        tester,
        control: find.byKey(const ValueKey('quick-action-reminders')),
        destination: find.textContaining('Reminder Preferences'),
      );
      expect(
        tester
            .widget<Switch>(
              find.byKey(const ValueKey('reminder-workouts')),
            )
            .value,
        isTrue,
      );
      expect(
        tester
            .widget<Switch>(
              find.byKey(const ValueKey('reminder-weight-records')),
            )
            .value,
        isTrue,
      );
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );

  testWidgets(
    'creates, edits, restores, and deletes weight records and goals',
    (tester) async {
      addTearDown(() => harness.dispose(tester));
      await harness.launchFresh(tester);
      await harness.onboard(
        tester,
        name: 'Weight Journey',
        preloadWorkouts: false,
      );

      await harness.tapAndWait(
        tester,
        control: find.byKey(const ValueKey('quick-action-weight-records')),
        destination: find.textContaining('Weight Logs'),
      );
      await tester.tap(find.byKey(const ValueKey('weight-record-add')));
      await harness.pumpUntilFound(tester, find.text('LOG WEIGHT'));
      await _enterField(tester, 'Weight', '82.50');
      await _enterField(tester, 'Body Fat Percentage', '18.50');
      await tester.tap(find.text('LOG WEIGHT'));
      await harness.pumpUntilFound(tester, find.textContaining('82.50 KG'));

      await tester.tap(
        find.byKey(const ValueKey('latest-weight-record-edit')),
      );
      await harness.pumpUntilFound(tester, find.text('UPDATE WEIGHT LOG'));
      await _enterField(tester, 'Weight', '81.25');
      await _enterField(tester, 'Body Fat Percentage', '17.50');
      await tester.tap(find.text('UPDATE WEIGHT LOG'));
      await harness.pumpUntilFound(tester, find.textContaining('81.25 KG'));

      await harness.pageBack(
        tester,
        find.byKey(const ValueKey('main-bottom-navigation')),
      );
      await harness.selectBottomNavigation(tester, 'Home');
      await harness.tapAndWait(
        tester,
        control: find.byKey(const ValueKey('quick-action-weight-goal')),
        destination: find.textContaining('Weight Goals'),
      );
      await tester.tap(find.byKey(const ValueKey('weight-goal-add')));
      await harness.pumpUntilFound(tester, find.text('CREATE WEIGHT GOAL'));
      await _enterField(tester, 'Weight', '75.00');
      await tester.tap(find.text('CREATE WEIGHT GOAL'));
      await harness.pumpUntilFound(tester, find.textContaining('75.00 KG'));

      await tester.tap(find.byKey(const ValueKey('active-weight-goal-edit')));
      await harness.pumpUntilFound(tester, find.text('UPDATE'));
      await _enterField(tester, 'Weight', '76.00');
      await tester.tap(find.text('UPDATE'));
      await harness.pumpUntilFound(tester, find.textContaining('76.00 KG'));

      await harness.restartPreservingData(tester);
      await harness.pumpUntilFound(
        tester,
        find.byKey(const ValueKey('main-bottom-navigation')),
      );
      final db = await DatabaseHelper().db;
      expect(await _count(db, WeightRecord.table), 1);
      expect(await _count(db, WeightGoal.table), 1);

      await harness.tapAndWait(
        tester,
        control: find.byKey(const ValueKey('quick-action-weight-records')),
        destination: find.textContaining('Weight Logs'),
      );
      await harness.pumpUntilFound(tester, find.textContaining('81.25 KG'));
      await tester.tap(
        find.byKey(const ValueKey('latest-weight-record-delete')),
      );
      await harness.pumpUntilFound(tester, find.text('DELETE WEIGHT LOG'));
      await tester.tap(find.text('CONFIRM'));
      await harness.pumpUntilFound(tester, find.text('No weight logs'));

      await harness.pageBack(
        tester,
        find.byKey(const ValueKey('main-bottom-navigation')),
      );
      await harness.selectBottomNavigation(tester, 'Home');
      await harness.tapAndWait(
        tester,
        control: find.byKey(const ValueKey('quick-action-weight-goal')),
        destination: find.textContaining('Weight Goals'),
      );
      await harness.pumpUntilFound(tester, find.textContaining('76.00 KG'));
      await tester.tap(find.byKey(const ValueKey('active-weight-goal-delete')));
      await harness.pumpUntilFound(tester, find.text('DELETE WEIGHT GOAL'));
      await tester.tap(find.text('CONFIRM'));
      await harness.pumpUntilFound(tester, find.text('No Weight Goal'));
      expect(await _count(db, WeightRecord.table), 0);
      expect(await _count(db, WeightGoal.table), 0);
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

Future<void> _chooseDropdownValue<T>(
  WidgetTester tester, {
  required Key containerKey,
  required String label,
}) async {
  final selector = find.descendant(
    of: find.byKey(containerKey),
    matching: find.byWidgetPredicate((widget) => widget is DropdownButton<T>),
  );
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (selector.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(selector, findsOneWidget);
  await tester.ensureVisible(selector);
  await tester.tap(selector);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text(label).last);
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _setSwitch(
  WidgetTester tester,
  Key key,
  bool value,
) async {
  final finder = find.byKey(key);
  final current = tester.widget<Switch>(finder);
  if (current.value != value) {
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 500));
  }
  expect(tester.widget<Switch>(finder).value, value);
}

Future<void> _enterField(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

Future<int> _count(Database db, String table) async {
  return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'),
      ) ??
      0;
}
