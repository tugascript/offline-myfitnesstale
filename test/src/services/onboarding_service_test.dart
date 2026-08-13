import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/models/constants/exercise_constants.dart';
import 'package:myfitnesstale/src/models/constants/workout_constants.dart';
import 'package:myfitnesstale/src/models/constants/workout_plan_constants.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/equipment_model.dart';
import 'package:myfitnesstale/src/models/exercise_equipment_model.dart';
import 'package:myfitnesstale/src/models/exercise_model.dart';
import 'package:myfitnesstale/src/models/profile_model.dart';
import 'package:myfitnesstale/src/models/reminders_config_model.dart';
import 'package:myfitnesstale/src/models/system_model.dart';
import 'package:myfitnesstale/src/models/workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_day_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_week_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_workout_model.dart';
import 'package:myfitnesstale/src/models/workout_set_exercise_model.dart';
import 'package:myfitnesstale/src/models/workout_set_exercise_option_model.dart';
import 'package:myfitnesstale/src/models/workout_set_model.dart';
import 'package:myfitnesstale/src/services/onboarding_service.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  const onboardingTables = [
    Profile.table,
    System.table,
    RemindersConfig.table,
    Equipment.table,
    Exercise.table,
    ExerciseEquipment.table,
    Workout.table,
    WorkoutSet.table,
    WorkoutSetExercise.table,
    WorkoutSetExerciseOption.table,
    WorkoutPlan.table,
    WorkoutPlanWeek.table,
    WorkoutPlanDay.table,
    WorkoutPlanWorkout.table,
  ];

  final birthday = DateTime(1992, 6, 15);
  final requestWithoutWorkouts = OnboardingRequest(
    units: Units.metric,
    theme: ThemeType.system,
    name: 'Atomic Tester',
    height: 176,
    gender: Gender.other,
    birthday: birthday,
    createWorkouts: false,
    notificationsOn: true,
  );

  final requestWithWorkouts = OnboardingRequest(
    units: Units.imperial,
    theme: ThemeType.dark,
    name: 'Seed Tester',
    height: 180,
    gender: Gender.male,
    birthday: birthday,
    createWorkouts: true,
    notificationsOn: false,
  );

  Future<int> count(String table) async {
    final db = await testDatabase.db;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $table'),
        ) ??
        0;
  }

  Future<Map<String, int>> counts() async {
    return {
      for (final table in onboardingTables) table: await count(table),
    };
  }

  Future<void> expectEmptyOnboardingDatabase() async {
    expect(
      await counts(),
      {for (final table in onboardingTables) table: 0},
    );
  }

  Future<void> expectCoreSeedCounts({required bool withWorkouts}) async {
    expect(await count(Profile.table), 1);
    expect(await count(System.table), 1);
    expect(await count(RemindersConfig.table), 1);
    expect(await count(Equipment.table), 25);
    expect(await count(Exercise.table), 86);
    expect(
      await count(ExerciseEquipment.table),
      kInitialExercises.fold<int>(
        0,
        (total, exercise) => total + exercise.equipments.length,
      ),
    );
    expect(await count(Workout.table), withWorkouts ? 16 : 0);
    expect(await count(WorkoutPlan.table), withWorkouts ? 1 : 0);
  }

  setUpAll(testDatabase.initialize);
  tearDown(testDatabase.clearOnboardingTables);
  tearDownAll(testDatabase.destroy);

  test('commits core onboarding without optional workouts', () async {
    expect(kInitialExercises, hasLength(86));
    final result = await OnboardingService().onboard(requestWithoutWorkouts);

    expect(result.isOk(), isTrue);
    expect(result.value.profile.name, 'Atomic Tester');
    expect(result.value.system.initialSetup, SetUpStatus.completed);
    expect(result.value.system.notificationsOn, isTrue);
    expect(result.value.remindersConfig.workoutsOn, isTrue);
    expect(result.value.remindersConfig.weightRecordsOn, isTrue);
    await expectCoreSeedCounts(withWorkouts: false);
    final db = await testDatabase.db;
    expect(
      System.fromMap((await db.query(System.table, limit: 1)).single)
          .initialSetup,
      SetUpStatus.completed,
    );
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });

  test('commits the complete optional workout and plan seed', () async {
    expect(kStandardWorkouts, hasLength(16));
    final result = await OnboardingService().onboard(requestWithWorkouts);

    expect(result.isOk(), isTrue);
    expect(result.value.system.initialSetup, SetUpStatus.completed);
    await expectCoreSeedCounts(withWorkouts: true);

    final db = await testDatabase.db;
    final plan = WorkoutPlan.fromMap(
      (await db.query(WorkoutPlan.table, limit: 1)).single,
    );
    expect(plan.name, kWorkoutPlanData.name);
    expect(plan.totalWeeks, 16);
    expect(await count(WorkoutPlanWeek.table), kWorkoutPlanData.weeks.length);
    expect(
      await count(WorkoutPlanDay.table),
      kWorkoutPlanData.weeks.fold<int>(
        0,
        (total, week) => total + week.days.length,
      ),
    );
    expect(
      await count(WorkoutPlanWorkout.table),
      kWorkoutPlanData.weeks.fold<int>(
        0,
        (total, week) =>
            total +
            week.days.fold<int>(
              0,
              (dayTotal, day) => dayTotal + day.workouts.length,
            ),
      ),
    );
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });

  for (final failureStage in OnboardingStage.values) {
    test('rolls back and retries after ${failureStage.name}', () async {
      var injected = false;
      final service = OnboardingService(
        afterStage: (stage) {
          if (stage == failureStage && !injected) {
            injected = true;
            throw StateError('Injected ${stage.name} failure');
          }
        },
      );

      final failure = await service.onboard(requestWithWorkouts);

      expect(failure.isErr(), isTrue);
      expect(failure.error.description, contains('No data was saved'));
      await expectEmptyOnboardingDatabase();

      final retry = await service.onboard(requestWithWorkouts);

      expect(retry.isOk(), isTrue);
      await expectCoreSeedCounts(withWorkouts: true);
      expect(
        await (await testDatabase.db).rawQuery('PRAGMA foreign_key_check'),
        isEmpty,
      );
    });
  }

  test('completed onboarding is idempotent', () async {
    final service = OnboardingService();
    final first = await service.onboard(requestWithWorkouts);
    expect(first.isOk(), isTrue);
    final originalCounts = await counts();

    final second = await service.onboard(OnboardingRequest(
      units: Units.metric,
      theme: ThemeType.light,
      name: 'Ignored retry values',
      height: 150,
      gender: Gender.female,
      birthday: DateTime(2000),
      createWorkouts: false,
      notificationsOn: true,
    ));

    expect(second.isOk(), isTrue);
    expect(second.value.profile.id, first.value.profile.id);
    expect(second.value.system.id, first.value.system.id);
    expect(second.value.remindersConfig.id, first.value.remindersConfig.id);
    expect(second.value.profile.name, requestWithWorkouts.name);
    expect(second.value.system.units, requestWithWorkouts.units);
    expect(await counts(), originalCounts);
  });

  test('rejects an inconsistent legacy database with reset guidance', () async {
    final db = await testDatabase.db;
    await db.insert(
      Equipment.table,
      Equipment.create(
        name: 'Partial legacy equipment',
        createdBy: CreatedBy.system,
      ).toMap(),
    );

    final result = await OnboardingService().onboard(requestWithoutWorkouts);

    expect(result.isErr(), isTrue);
    expect(result.error.description, contains('Clear app data'));
    expect(result.error.description, contains('saved no data'));
    expect(await count(Equipment.table), 1);
    expect(await count(Profile.table), 0);
  });
}
