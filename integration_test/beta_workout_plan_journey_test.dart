import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/models/db.dart';
import 'package:myfitnesstale/src/models/workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_day_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_record_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_week_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_workout_record_model.dart';

import 'support/device_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final harness = DeviceTestHarness();

  testWidgets(
    'creates and edits a plan, completes scheduled live and manual workouts, and restores history',
    (tester) async {
      addTearDown(() => harness.dispose(tester));
      await harness.launchFresh(tester);
      await harness.onboard(
        tester,
        name: 'Plan Journey',
        preloadWorkouts: true,
      );

      var db = await DatabaseHelper().db;
      final workoutNames = await _firstWorkoutNames(db, 2);

      await harness.selectBottomNavigation(tester, 'Plans');
      await harness.pumpUntilFound(
          tester, find.textContaining('Workout Plans'));
      await tester.tap(find.byKey(const ValueKey('workout-plan-add')));
      await harness.pumpUntilFound(tester, find.text('CREATE WORKOUT PLAN'));
      await _enterField(tester, 'Name', 'Journey Plan');
      await tester.tap(find.text('CREATE WORKOUT PLAN'));
      await harness.pumpUntilFound(tester, find.text('START PLAN'));

      await tester.ensureVisible(find.text('EDIT'));
      await tester.tap(find.text('EDIT'));
      await harness.pumpUntilFound(tester, find.text('Add Week Block'));
      await tester.tap(
        find.byKey(const ValueKey('workout-plan-header-edit')),
      );
      await harness.pumpUntilFound(tester, find.text('UPDATE WORKOUT PLAN'));
      await _enterField(tester, 'Name', 'Journey Plan Updated');
      await tester.ensureVisible(find.text('UPDATE WORKOUT PLAN'));
      await tester.tap(find.text('UPDATE WORKOUT PLAN'));
      await harness.pumpUntilAbsent(tester, find.text('UPDATE WORKOUT PLAN'));

      await tester.ensureVisible(find.text('Add Week Block'));
      await tester.tap(find.text('Add Week Block'));
      await harness.pumpUntilFound(tester, find.text('Add Workout'));
      await tester.ensureVisible(find.text('Add Workout'));
      await tester.tap(find.text('Add Workout'));
      await harness.pumpUntilFound(tester, find.text(workoutNames[0]));
      await tester.tap(find.text(workoutNames[0]).last);
      await harness.pumpUntilAbsent(tester, find.byType(Dialog));

      await tester.ensureVisible(find.text('Add Workout'));
      await tester.tap(find.text('Add Workout'));
      await harness.pumpUntilFound(tester, find.text(workoutNames[1]));
      await tester.tap(find.text(workoutNames[1]).last);
      await harness.pumpUntilAbsent(tester, find.byType(Dialog));

      final savePlan = find.text('SAVE');
      await tester.ensureVisible(savePlan);
      await tester.tap(savePlan);
      await harness.pumpUntilFound(tester, find.text('START PLAN'));

      final plan = await _planByName(db, 'Journey Plan Updated');
      final planId = plan['id'] as int;
      final planVersion = plan['version'] as int;
      expect(
        await _countWhere(
          db,
          WorkoutPlanWeek.table,
          'workout_plan_id = ? AND plan_version = ?',
          [planId, planVersion],
        ),
        1,
      );
      expect(
        await _countWhere(
          db,
          WorkoutPlanDay.table,
          'workout_plan_id = ? AND plan_version = ?',
          [planId, planVersion],
        ),
        1,
      );
      expect(
        await _countWhere(
          db,
          WorkoutPlanWorkout.table,
          'workout_plan_id = ? AND plan_version = ?',
          [planId, planVersion],
        ),
        2,
      );

      await tester.ensureVisible(find.text('START PLAN'));
      await tester.tap(find.text('START PLAN'));
      await harness.pumpUntilFound(tester, find.text(workoutNames[0]));
      await harness.pumpUntilFound(tester, find.text('Start'));
      expect(
        await _countWhere(
          db,
          WorkoutPlanRecord.table,
          'workout_plan_id = ? AND status = ?',
          [planId, 'in_progress'],
        ),
        1,
      );

      await harness.restartPreservingData(tester);
      db = await DatabaseHelper().db;
      await harness.goAndWait(
        tester,
        location: '/workout-plans/$planId/active',
        destination: find.text(workoutNames[0]),
      );
      await harness.pumpUntilFound(tester, find.text('Start'));
      expect(
        await _countWhere(
          db,
          WorkoutPlanRecord.table,
          'workout_plan_id = ? AND status = ?',
          [planId, 'in_progress'],
        ),
        1,
      );

      await tester.tap(find.text('Start').first);
      await harness.pumpUntilFound(tester, find.text('COMPLETE'));
      await tester.ensureVisible(find.text('COMPLETE'));
      await tester.tap(find.text('COMPLETE'));
      await harness.pumpUntilFound(tester, find.text('Completed'));
      await harness.pumpUntilFound(tester, find.text('Log'));
      expect(
        await _countWhere(
          db,
          WorkoutPlanWorkoutRecord.table,
          'workout_plan_record_id = (SELECT id FROM workout_plan_records WHERE workout_plan_id = ? LIMIT 1) AND status = ?',
          [planId, 'completed'],
        ),
        1,
      );

      final logWorkout = find.text('Log');
      await tester.ensureVisible(logWorkout);
      await tester.tap(logWorkout);
      await harness.pumpUntilFound(tester, find.text('Create Workout Record'));
      await tester.pump(const Duration(milliseconds: 500));
      final saveRecord = find.text('SAVE WORKOUT RECORD');
      await tester.ensureVisible(saveRecord);
      await tester.tap(saveRecord);
      await harness.pumpUntilFound(
        tester,
        find.text('Workout record saved and added to the plan.'),
      );
      await harness.pumpUntilAbsent(tester, find.text('Create Workout Record'));

      expect(
        await _countWhere(
          db,
          WorkoutPlanWorkoutRecord.table,
          'workout_plan_record_id = (SELECT id FROM workout_plan_records WHERE workout_plan_id = ? LIMIT 1) AND status = ?',
          [planId, 'completed'],
        ),
        2,
      );
      expect(
        await _countWhere(
          db,
          WorkoutPlanRecord.table,
          'workout_plan_id = ? AND status = ?',
          [planId, 'completed'],
        ),
        1,
      );
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 2000),
        3000,
      );
      await tester.pump(const Duration(milliseconds: 450));
      await harness.pumpUntilFound(tester, find.text('100.0%'));

      await harness.goAndWait(
        tester,
        location: '/workout-plans/$planId/history',
        destination: find.textContaining('Plan History'),
      );
      await harness.pumpUntilFound(tester, find.text('Completed'));
      expect(find.text('Version $planVersion'), findsOneWidget);

      await harness.restartPreservingData(tester);
      db = await DatabaseHelper().db;
      expect(
        await _countWhere(
          db,
          WorkoutPlanRecord.table,
          'workout_plan_id = ? AND status = ?',
          [planId, 'completed'],
        ),
        1,
      );
      await harness.goAndWait(
        tester,
        location: '/workout-plans/$planId/history',
        destination: find.textContaining('Plan History'),
      );
      await harness.pumpUntilFound(tester, find.text('Completed'));
      expect(find.textContaining('Not Found'), findsNothing);
    },
    timeout: const Timeout(Duration(minutes: 15)),
  );
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

Future<List<String>> _firstWorkoutNames(Database db, int limit) async {
  final rows = await db.query(
    Workout.table,
    columns: ['name'],
    orderBy: 'name COLLATE NOCASE ASC',
    limit: limit,
  );
  expect(rows.length, greaterThanOrEqualTo(limit));
  return rows.map((row) => row['name'] as String).toList();
}

Future<Map<String, Object?>> _planByName(Database db, String name) async {
  final rows = await db.query(
    WorkoutPlan.table,
    where: 'name = ?',
    whereArgs: [name],
    limit: 1,
  );
  expect(rows, hasLength(1));
  return rows.single;
}

Future<int> _countWhere(
  Database db,
  String table,
  String where,
  List<Object?> whereArgs,
) async {
  return Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM $table WHERE $where',
          whereArgs,
        ),
      ) ??
      0;
}
