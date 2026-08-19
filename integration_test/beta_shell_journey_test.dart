import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/models/constants/workout_plan_constants.dart';
import 'package:myfitnesstale/src/models/db.dart';
import 'package:myfitnesstale/src/models/workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_model.dart';

import 'support/device_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final harness = DeviceTestHarness();

  testWidgets(
    'onboards without optional workouts and reaches every shell destination',
    (tester) async {
      addTearDown(() => harness.dispose(tester));
      await harness.launchFresh(tester);
      await harness.onboard(
        tester,
        name: 'Shell Journey',
        preloadWorkouts: false,
      );

      await _visitBottomNavigation(tester, harness);
      await _visitQuickActions(tester, harness);
      await _visitActivityDestinations(tester, harness);
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );

  testWidgets(
    'onboards with optional workouts and restores the committed profile',
    (tester) async {
      addTearDown(() => harness.dispose(tester));
      await harness.launchFresh(tester);
      await harness.onboard(
        tester,
        name: 'Persistence Journey',
        preloadWorkouts: true,
      );

      final db = await DatabaseHelper().db;
      expect(
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${Workout.table}'),
        ),
        16,
      );
      expect(
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${WorkoutPlan.table}'),
        ),
        1,
      );

      await harness.selectBottomNavigation(tester, 'Plans');
      await harness.pumpUntilFound(tester, find.text(kWorkoutPlanData.name));

      await harness.selectBottomNavigation(tester, 'Home');
      await harness.tapAndWait(
        tester,
        control: find.byKey(const ValueKey('quick-action-workouts')),
        destination: find.textContaining('Workouts'),
      );

      await harness.restartPreservingData(tester);
      await harness.pumpUntilFound(
        tester,
        find.byKey(const ValueKey('main-bottom-navigation')),
      );
      expect(find.text('Welcome'), findsNothing);

      await harness.selectBottomNavigation(tester, 'Profile');
      await harness.pumpUntilFound(tester, find.text('Persistence Journey'));
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

Future<void> _visitBottomNavigation(
  WidgetTester tester,
  DeviceTestHarness harness,
) async {
  const destinations = {
    'Plans': 'Workout Plans',
    'Activity': 'Activity',
    'Profile': 'Profile',
    'Home': 'My Fitness Tale',
  };

  for (final entry in destinations.entries) {
    await harness.selectBottomNavigation(tester, entry.key);
    await harness.pumpUntilFound(tester, find.textContaining(entry.value));
    expect(find.textContaining('Not Found'), findsNothing);
  }
}

Future<void> _visitQuickActions(
  WidgetTester tester,
  DeviceTestHarness harness,
) async {
  const destinations = {
    'quick-action-weight-goal': 'Weight Goals',
    'quick-action-weight-records': 'Weight Logs',
    'quick-action-workouts': 'Workouts',
    'quick-action-exercises': 'Exercises',
    'quick-action-equipments': 'Equipments',
    'quick-action-reminders': 'Reminder Preferences',
  };

  for (final entry in destinations.entries) {
    await harness.selectBottomNavigation(tester, 'Home');
    await harness.tapAndWait(
      tester,
      control: find.byKey(ValueKey(entry.key)),
      destination: find.textContaining(entry.value),
    );
    await harness.pageBack(
      tester,
      find.byKey(const ValueKey('main-bottom-navigation')),
    );
  }
}

Future<void> _visitActivityDestinations(
  WidgetTester tester,
  DeviceTestHarness harness,
) async {
  const destinations = {
    'activity-workout-history': 'Workouts',
    'activity-exercise-progress': 'Exercise Progress',
    'activity-weight-history': 'Weight Logs',
    'activity-plan-history': 'Workout Plans',
  };

  for (final entry in destinations.entries) {
    await harness.selectBottomNavigation(tester, 'Activity');
    await harness.tapAndWait(
      tester,
      control: find.byKey(ValueKey(entry.key)),
      destination: find.textContaining(entry.value),
    );
    await harness.pageBack(
      tester,
      find.byKey(const ValueKey('main-bottom-navigation')),
    );
  }
}
