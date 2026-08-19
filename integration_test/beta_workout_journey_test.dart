import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/models/db.dart';
import 'package:myfitnesstale/src/models/exercise_model.dart';
import 'package:myfitnesstale/src/models/workout_model.dart';
import 'package:myfitnesstale/src/models/workout_record_model.dart';
import 'package:myfitnesstale/src/models/workout_set_exercise_model.dart';
import 'package:myfitnesstale/src/models/workout_set_model.dart';

import 'support/device_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final harness = DeviceTestHarness();

  testWidgets(
    'creates and edits a workout, resumes and cancels live work, then records history',
    (tester) async {
      addTearDown(() => harness.dispose(tester));
      await harness.launchFresh(tester);
      await harness.onboard(
        tester,
        name: 'Workout Journey',
        preloadWorkouts: false,
      );

      var db = await DatabaseHelper().db;
      final exerciseName = await _firstExerciseName(db);

      await harness.tapAndWait(
        tester,
        control: find.byKey(const ValueKey('quick-action-workouts')),
        destination: find.textContaining('Workouts'),
      );
      await tester.tap(find.byKey(const ValueKey('workout-add')));
      await harness.pumpUntilFound(tester, find.text('CREATE WORKOUT'));
      await _enterField(tester, 'Name', 'Journey Workout');
      await tester.tap(find.text('CREATE WORKOUT'));
      await harness.pumpUntilFound(tester, find.text('START WORKOUT'));

      await tester.ensureVisible(find.text('EDIT'));
      await tester.tap(find.text('EDIT'));
      await harness.pumpUntilFound(tester, find.text('Add Set'));
      await tester.ensureVisible(find.text('Add Set'));
      await tester.tap(find.text('Add Set'));
      await harness.pumpUntilFound(tester, find.text(exerciseName));
      await tester.tap(find.text(exerciseName).first);
      await harness.pumpUntilAbsent(tester, find.byType(Dialog));
      final saveSets = find.text('SAVE');
      await tester.ensureVisible(saveSets);
      await tester.tap(saveSets);
      await harness.pumpUntilFound(tester, find.text('START WORKOUT'));

      await tester.ensureVisible(find.text('EDIT'));
      await tester.tap(find.text('EDIT'));
      await harness.pumpUntilFound(
        tester,
        find.byKey(const ValueKey('workout-header-edit')),
      );
      await tester.tap(find.byKey(const ValueKey('workout-header-edit')));
      await harness.pumpUntilFound(tester, find.text('UPDATE WORKOUT'));
      await _enterField(tester, 'Name', 'Journey Workout Updated');
      await tester.ensureVisible(find.text('UPDATE WORKOUT'));
      await tester.tap(find.text('UPDATE WORKOUT'));
      await harness.pumpUntilAbsent(tester, find.text('UPDATE WORKOUT'));
      await tester.ensureVisible(find.text('SAVE'));
      await tester.tap(find.text('SAVE'));
      await harness.pumpUntilFound(tester, find.text('START WORKOUT'));

      final workout = await _workoutByName(db, 'Journey Workout Updated');
      final workoutId = workout['id'] as int;
      final version = workout['version'] as int;
      expect(
        await _countWhere(
          db,
          WorkoutSet.table,
          'workout_id = ? AND workout_version = ?',
          [workoutId, version],
        ),
        1,
      );
      expect(
        await _countWhere(
          db,
          WorkoutSetExercise.table,
          'workout_id = ? AND workout_version = ?',
          [workoutId, version],
        ),
        1,
      );

      await tester.ensureVisible(find.text('START WORKOUT'));
      await tester.tap(find.text('START WORKOUT'));
      await harness.pumpUntilFound(tester, find.text('LOG SET'));
      final activeRecordId = await _singleRecordId(db, workoutId);

      await harness.restartPreservingData(tester);
      db = await DatabaseHelper().db;
      expect(await _singleRecordId(db, workoutId), activeRecordId);
      await harness.goAndWait(
        tester,
        location: '/workouts/$workoutId/active',
        destination: find.text('LOG SET'),
      );
      expect(await _singleRecordId(db, workoutId), activeRecordId);
      await tester.ensureVisible(find.text('CANCEL'));
      await tester.tap(find.text('CANCEL'));
      await harness.pumpUntilFound(tester, find.text('Cancel Workout'));
      await tester.tap(find.text('Yes, Cancel'));
      await harness.pumpUntilFound(tester, find.text('START WORKOUT'));
      expect(
        await _countWhere(
          db,
          WorkoutRecord.table,
          'workout_id = ?',
          [workoutId],
        ),
        0,
      );

      await tester.tap(find.text('START WORKOUT'));
      await harness.pumpUntilFound(tester, find.text('LOG SET'));
      await tester.ensureVisible(find.text('COMPLETE'));
      await tester.tap(find.text('COMPLETE'));
      await harness.pumpUntilFound(tester, find.text('START WORKOUT'));
      expect(
        await _countWhere(
          db,
          WorkoutRecord.table,
          'workout_id = ? AND status = ?',
          [workoutId, 'completed'],
        ),
        1,
      );

      await tester.ensureVisible(find.text('HISTORY'));
      await tester.tap(find.text('HISTORY'));
      await harness.pumpUntilFound(tester, find.text('Latest Record'));
      await tester.tap(find.byKey(const ValueKey('workout-record-add')));
      await harness.pumpUntilFound(tester, find.text('Create Workout Record'));
      await _enterKeyedField(
        tester,
        const ValueKey('manual-weight-input'),
        '30',
      );
      await _enterKeyedField(
        tester,
        const ValueKey('manual-reps-input'),
        '8',
      );
      final saveRecord = find.text('SAVE WORKOUT RECORD');
      await tester.ensureVisible(saveRecord);
      await tester.tap(saveRecord);
      await harness.pumpUntilFound(tester, find.text('Workout record saved.'));
      await harness.pumpUntilAbsent(tester, find.text('Create Workout Record'));
      expect(
        await _countWhere(
          db,
          WorkoutRecord.table,
          'workout_id = ? AND status = ?',
          [workoutId, 'completed'],
        ),
        2,
      );

      await harness.restartPreservingData(tester);
      db = await DatabaseHelper().db;
      expect(
        await _countWhere(
          db,
          WorkoutRecord.table,
          'workout_id = ? AND status = ?',
          [workoutId, 'completed'],
        ),
        2,
      );
      await harness.goAndWait(
        tester,
        location: '/workouts/$workoutId/history/$version',
        destination: find.text('Latest Record'),
      );
      expect(find.textContaining('Not Found'), findsNothing);
    },
    timeout: const Timeout(Duration(minutes: 12)),
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

Future<void> _enterKeyedField(
  WidgetTester tester,
  Key key,
  String value,
) async {
  final field = find.descendant(
    of: find.byKey(key),
    matching: find.byType(TextFormField),
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

Future<String> _firstExerciseName(Database db) async {
  final rows = await db.query(
    Exercise.table,
    columns: ['name'],
    orderBy: 'name COLLATE NOCASE ASC',
    limit: 1,
  );
  return rows.single['name'] as String;
}

Future<Map<String, Object?>> _workoutByName(Database db, String name) async {
  final rows = await db.query(
    Workout.table,
    where: 'name = ?',
    whereArgs: [name],
    limit: 1,
  );
  expect(rows, hasLength(1));
  return rows.single;
}

Future<int> _singleRecordId(Database db, int workoutId) async {
  final rows = await db.query(
    WorkoutRecord.table,
    columns: ['id'],
    where: 'workout_id = ?',
    whereArgs: [workoutId],
  );
  expect(rows, hasLength(1));
  return rows.single['id'] as int;
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
