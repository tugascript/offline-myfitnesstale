import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/models/db.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/equipment_model.dart';
import 'package:myfitnesstale/src/models/exercise_model.dart';
import 'package:myfitnesstale/src/models/exercise_record_model.dart';

import 'support/device_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final harness = DeviceTestHarness();

  testWidgets(
    'creates, edits, restores, and deletes equipment and an exercise record',
    (tester) async {
      addTearDown(() => harness.dispose(tester));
      await harness.launchFresh(tester);
      await harness.onboard(
        tester,
        name: 'Exercise Journey',
        preloadWorkouts: false,
      );

      await harness.tapAndWait(
        tester,
        control: find.byKey(const ValueKey('quick-action-equipments')),
        destination: find.textContaining('Equipments'),
      );
      await tester.tap(find.byKey(const ValueKey('equipment-add')));
      await harness.pumpUntilFound(
          tester, find.textContaining('Create Equipment'));
      await _enterField(tester, 'Name', 'Journey Machine');
      await tester.tap(find.text('CREATE'));
      await harness.pumpUntilAbsent(tester, find.text('CREATE'));
      await harness.pumpUntilFound(tester, find.text('Journey Machine'));
      await tester.tap(find.text('Journey Machine').first);
      await harness.pumpUntilFound(
          tester, find.textContaining('JOURNEY MACHINE'));
      await tester.tap(find.text('EDIT'));
      await harness.pumpUntilFound(tester, find.text('UPDATE'));
      await _enterField(tester, 'Name', 'Journey Cable Machine');
      await tester.tap(find.text('UPDATE'));
      await harness.pumpUntilFound(
        tester,
        find.textContaining('JOURNEY CABLE MACHINE'),
      );

      var db = await DatabaseHelper().db;
      final equipmentId = await _idForName(
        db,
        Equipment.table,
        'Journey Cable Machine',
      );
      expect(equipmentId, isNotNull);

      await harness.restartPreservingData(tester);
      db = await DatabaseHelper().db;
      expect(
        await _countWhere(
          db,
          Equipment.table,
          'name = ?',
          ['Journey Cable Machine'],
        ),
        1,
      );

      await harness.goAndWait(
        tester,
        location: '/exercises/create',
        destination: find.textContaining('Create Exercise'),
      );
      await _enterField(tester, 'Name', 'Journey Press');
      await _chooseDropdown<MuscleGroup>(tester, 'Full Body');
      final createExercise = find.text('CREATE');
      await tester.ensureVisible(createExercise);
      await tester.tap(createExercise);
      await harness.pumpUntilFound(
          tester, find.textContaining('JOURNEY PRESS'));

      await tester.ensureVisible(find.text('EDIT'));
      await tester.tap(find.text('EDIT'));
      await harness.pumpUntilFound(tester, find.text('UPDATE'));
      await _enterField(tester, 'Name', 'Journey Chest Press');
      final updateExercise = find.text('UPDATE');
      await tester.ensureVisible(updateExercise);
      await tester.tap(updateExercise);
      await harness.pumpUntilAbsent(tester, updateExercise);
      await harness.pumpUntilFound(tester, find.text('LOG PROGRESS'));

      final exerciseId = await _idForName(
        db,
        Exercise.table,
        'Journey Chest Press',
      );
      expect(exerciseId, isNotNull);
      await tester.tap(find.text('LOG PROGRESS'));
      await harness.pumpUntilFound(
        tester,
        find.textContaining('JOURNEY CHEST PRESS RECORDS'),
      );
      await tester.tap(find.byKey(const ValueKey('exercise-record-add')));
      await harness.pumpUntilFound(
        tester,
        find.text('CREATE EXERCISE RECORD'),
      );
      await _enterField(tester, 'Weight', '20.00');
      final createRecord = find.text('CREATE EXERCISE RECORD');
      await tester.ensureVisible(createRecord);
      await tester.tap(createRecord);
      await harness.pumpUntilFound(tester, find.textContaining('20.00 KG'));

      await tester.tap(
        find.byKey(const ValueKey('latest-exercise-record-edit')),
      );
      await harness.pumpUntilFound(tester, find.text('UPDATE'));
      await _enterField(tester, 'Weight', '25.00');
      final updateRecord = find.text('UPDATE');
      await tester.ensureVisible(updateRecord);
      await tester.tap(updateRecord);
      await harness.pumpUntilFound(tester, find.textContaining('25.00 KG'));

      await harness.restartPreservingData(tester);
      db = await DatabaseHelper().db;
      expect(
        await _countWhere(
          db,
          ExerciseRecord.table,
          'exercise_id = ?',
          [exerciseId],
        ),
        1,
      );
      await harness.goAndWait(
        tester,
        location: '/exercises/$exerciseId/records',
        destination: find.textContaining('JOURNEY CHEST PRESS RECORDS'),
      );
      await harness.pumpUntilFound(tester, find.textContaining('25.00 KG'));
      await tester.tap(
        find.byKey(const ValueKey('latest-exercise-record-delete')),
      );
      await harness.pumpUntilFound(tester, find.text('DELETE EXERCISE RECORD'));
      await tester.tap(find.text('DELETE'));
      await harness.pumpUntilFound(
        tester,
        find.text('No Journey Chest Press records'),
      );
      expect(
        await _countWhere(
          db,
          ExerciseRecord.table,
          'exercise_id = ?',
          [exerciseId],
        ),
        0,
      );

      await harness.goAndWait(
        tester,
        location: '/exercises/$exerciseId',
        destination: find.text('LOG PROGRESS'),
      );
      await tester.ensureVisible(find.text('DELETE'));
      await tester.tap(find.text('DELETE'));
      await harness.pumpUntilFound(tester, find.text('DELETE EXERCISE'));
      await tester.tap(find.text('DELETE').last);
      await harness.pumpUntilAbsent(
        tester,
        find.textContaining('JOURNEY CHEST PRESS'),
      );
      expect(
        await _countWhere(
          db,
          Exercise.table,
          'id = ?',
          [exerciseId],
        ),
        0,
      );

      await harness.goAndWait(
        tester,
        location: '/equipments/$equipmentId',
        destination: find.textContaining('JOURNEY CABLE MACHINE'),
      );
      await tester.tap(find.text('DELETE'));
      await harness.pumpUntilFound(
          tester, find.text('DELETE JOURNEY CABLE MACHINE'));
      await tester.tap(find.text('CONFIRM'));
      await harness.pumpUntilAbsent(
        tester,
        find.textContaining('JOURNEY CABLE MACHINE'),
      );
      expect(
        await _countWhere(db, Equipment.table, 'id = ?', [equipmentId]),
        0,
      );
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

Future<void> _chooseDropdown<T>(WidgetTester tester, String label) async {
  final dropdown = find
      .byWidgetPredicate((widget) => widget is DropdownButtonFormField<T?>)
      .first;
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text(label).last);
  await tester.pump(const Duration(milliseconds: 300));
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

Future<int?> _idForName(Database db, String table, String name) async {
  final rows = await db.query(
    table,
    columns: ['id'],
    where: 'name = ?',
    whereArgs: [name],
    limit: 1,
  );
  return rows.isEmpty ? null : rows.single['id'] as int;
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
