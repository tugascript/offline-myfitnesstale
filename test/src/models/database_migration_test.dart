// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/data/models/constants/equipment_constants.dart';
import 'package:myfitnesstale/src/data/models/constants/exercise_constants.dart';
import 'package:myfitnesstale/src/data/models/sqlite/equipment_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/exercise_equipment_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/exercise_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/profile_model.dart';
import 'package:myfitnesstale/src/data/models/sqlite/system_model.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/services/sqlite/database_helper.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'version 3 repairs equipment for completed legacy onboarding',
    () async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await DatabaseHelper().resetForTesting();

      final originalDatabasesPath = await databaseFactory.getDatabasesPath();
      final tempDirectory = await Directory.systemTemp.createTemp(
        'myfitnesstale_migration_test_',
      );
      await databaseFactory.setDatabasesPath(tempDirectory.path);

      addTearDown(() async {
        await DatabaseHelper().resetForTesting();
        await databaseFactory.setDatabasesPath(originalDatabasesPath);
        await tempDirectory.delete(recursive: true);
      });

      final legacyDatabase = await openDatabase(
        join(tempDirectory.path, 'app.db'),
        version: 2,
        onCreate: (database, _) async {
          for (final statement in [
            Profile.tableCreate,
            System.tableCreate,
            Equipment.tableCreate,
            Exercise.tableCreate,
            ExerciseEquipment.tableCreate,
          ]) {
            for (final query in statement.split(';')) {
              if (query.trim().isNotEmpty) {
                await database.execute(query.trim());
              }
            }
          }
        },
      );

      final profileId = await legacyDatabase.insert(
        Profile.table,
        Profile.create(
          name: 'Legacy Profile',
          height: 175,
          gender: Gender.other,
          birthdate: DateTime(1990),
        ).toMap(),
      );
      await legacyDatabase.insert(
        System.table,
        System.create(
          theme: ThemeType.system,
          units: Units.metric,
          profileId: profileId,
          notificationsOn: false,
        ).copyWith(initialSetup: SetUpStatus.completed).toMap(),
      );
      final exerciseId = await legacyDatabase.insert(
        Exercise.table,
        Exercise.create(
          name: kBarbellChestPressName,
          muscleGroup: MuscleGroup.push,
          muscles: const TargetMuscles(primary: {}, secondary: {}),
          difficulty: Difficulty.beginner,
          createdBy: CreatedBy.system,
        ).toMap(),
      );
      await legacyDatabase.close();

      await DatabaseHelper().initialize();
      final migratedDatabase = await DatabaseHelper().db;

      expect(await migratedDatabase.getVersion(), 3);
      expect(
        (await migratedDatabase.query(Equipment.table)).length,
        kEquipmentNames.length,
      );

      final relations = await migratedDatabase.query(
        ExerciseEquipment.table,
        columns: [ExerciseEquipmentColumns.equipmentId.value],
        where: '${ExerciseEquipmentColumns.exerciseId.value} = ?',
        whereArgs: [exerciseId],
      );
      final relatedEquipmentIds = relations
          .map((row) => row[ExerciseEquipmentColumns.equipmentId.value]! as int)
          .toSet();
      final expectedEquipmentRows = await migratedDatabase.query(
        Equipment.table,
        columns: [EquipmentColumns.id.value],
        where: '${EquipmentColumns.name.value} IN (?, ?)',
        whereArgs: [kBarbellName, kBenchName],
      );
      expect(
        relatedEquipmentIds,
        expectedEquipmentRows
            .map((row) => row[EquipmentColumns.id.value]! as int)
            .toSet(),
      );
      expect(
        await migratedDatabase.rawQuery('PRAGMA foreign_key_check'),
        isEmpty,
      );

      final equipmentService = ExerciseRepository.create();
      final paginatedEquipment = await equipmentService.getEquipments();
      final equipmentSelection = await equipmentService.getAllEquipments();
      expect(paginatedEquipment.isOk(), isTrue);
      expect(paginatedEquipment.value.total, kEquipmentNames.length);
      expect(paginatedEquipment.value.data, hasLength(kEquipmentNames.length));
      expect(equipmentSelection.isOk(), isTrue);
      expect(equipmentSelection.value, hasLength(kEquipmentNames.length));
    },
    skip: 'Pre-release schema version is 1; migrations deferred until external beta.',
  );
}
