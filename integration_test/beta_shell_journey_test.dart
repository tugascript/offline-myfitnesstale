import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/models/constants/workout_plan_constants.dart';
import 'package:myfitnesstale/src/models/db.dart';
import 'package:myfitnesstale/src/models/workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_record_model.dart';

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

      await harness.selectBottomNavigation(tester, 'Plan');
      await harness.pumpUntilFound(tester, find.text('No Active Workout Plan'));
      expect(
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${WorkoutPlanRecord.table}'),
        ),
        0,
      );
      await harness.tapAndWait(
        tester,
        control: find.byKey(const ValueKey('current-plan-browse-plans')),
        destination: find.textContaining('Workout Plans'),
      );
      await harness.pumpUntilFound(tester, find.text(kWorkoutPlanData.name));
      await harness.pageBack(tester, find.text('No Active Workout Plan'));

      await harness.selectBottomNavigation(tester, 'Home');
      await harness.openQuickAction(
        tester,
        category: 'training',
        destination: 'workouts',
        page: find.textContaining('Workouts'),
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
    'Plan': 'Current Plan',
    'Macros': 'Macro Tracker',
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
    'workouts': ('training', 'Workouts'),
    'workout-plans': ('training', 'Workout Plans'),
    'weight-records': ('weight', 'Weight Logs'),
    'weight-goal': ('weight', 'Weight Goals'),
    'exercises': ('exercises', 'Exercises'),
    'exercise-progress': ('exercises', 'Exercise Progress'),
    'strength-goals': ('exercises', 'Strength Goals'),
    'equipments': ('exercises', 'Equipments'),
    'macro-goals': ('nutrition', 'Macro Goals'),
    'meal-plans': ('nutrition', 'Meal Plans'),
    'recipe': ('nutrition', 'Recipes'),
    'food': ('nutrition', 'Foods'),
  };

  for (final entry in destinations.entries) {
    await harness.selectBottomNavigation(tester, 'Home');
    await harness.openQuickAction(
      tester,
      category: entry.value.$1,
      destination: entry.key,
      page: find.textContaining(entry.value.$2),
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
