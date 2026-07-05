import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:myfitnesstale/src/cubits/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/cubits/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/utilities.dart';
import 'package:myfitnesstale/src/models/workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_day_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_record_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_week_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_workout_model.dart';
import 'package:myfitnesstale/src/services/workout_plan_service.dart';

import '../../support/test_database.dart';

void main() {
  final testDatabase = TestDatabase();
  int seedCounter = 0;

  String uniqueName(String prefix) => '$prefix-${seedCounter++}';

  Future<int> createWorkout(Database db, String name) async {
    final workout = Workout.create(
      name: name,
      difficulty: Difficulty.beginner,
    );
    return db.insert(Workout.table, workout.toMap());
  }

  setUpAll(() async {
    await testDatabase.initialize();
  });

  tearDown(() async {
    await testDatabase.clearWorkoutPlanTables();
  });

  tearDownAll(() async {
    await testDatabase.destroy();
  });

  test('free users cannot create more than 3 workout plans', () async {
    final cubit = WorkoutPlanCubit();

    await cubit.createWorkoutPlan(
      name: uniqueName('plan'),
      totalWeeks: 0,
      difficulty: Difficulty.beginner,
      isFavorite: false,
    );
    await cubit.createWorkoutPlan(
      name: uniqueName('plan'),
      totalWeeks: 0,
      difficulty: Difficulty.beginner,
      isFavorite: false,
    );
    await cubit.createWorkoutPlan(
      name: uniqueName('plan'),
      totalWeeks: 0,
      difficulty: Difficulty.beginner,
      isFavorite: false,
    );
    await cubit.createWorkoutPlan(
      name: uniqueName('plan'),
      totalWeeks: 0,
      difficulty: Difficulty.beginner,
      isFavorite: false,
    );

    expect(cubit.state.error?.type, 'plan_limit_reached');

    final countResult =
        await WorkoutPlanService().countWorkoutPlans(createdBy: CreatedBy.user);
    expect(countResult.isOk(), isTrue);
    expect(countResult.value, 3);

    await cubit.close();
  });

  test('today mapping uses relative day index from plan start', () async {
    final db = await testDatabase.db;

    final workoutAId = await createWorkout(db, uniqueName('relative-a'));
    final workoutBId = await createWorkout(db, uniqueName('relative-b'));

    final plan = WorkoutPlan.create(
      name: uniqueName('relative-plan'),
      difficulty: Difficulty.beginner,
      version: 1,
      totalWeeks: 1,
      totalDays: 2,
      totalWorkouts: 2,
    );
    final planId = await db.insert(WorkoutPlan.table, plan.toMap());

    final week = WorkoutPlanWeek.create(
      workoutPlanId: planId,
      planVersion: 1,
      startWeek: 1,
      endWeek: 1,
      scheduleMode: WorkoutPlanWeekScheduleMode.manual,
      totalDays: 2,
      totalWorkouts: 2,
    );
    final weekId = await db.insert(WorkoutPlanWeek.table, week.toMap());

    final day1 = WorkoutPlanDay.create(
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      planVersion: 1,
      day: 1,
      totalWorkouts: 1,
      isRestDay: false,
    );
    final day1Id = await db.insert(WorkoutPlanDay.table, day1.toMap());

    final day2 = WorkoutPlanDay.create(
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      planVersion: 1,
      day: 2,
      totalWorkouts: 1,
      isRestDay: false,
    );
    final day2Id = await db.insert(WorkoutPlanDay.table, day2.toMap());

    final day1Workout = WorkoutPlanWorkout.create(
      position: 1,
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      workoutPlanDayId: day1Id,
      planVersion: 1,
      workoutId: workoutAId,
    );
    await db.insert(WorkoutPlanWorkout.table, day1Workout.toMap());

    final day2Workout = WorkoutPlanWorkout.create(
      position: 1,
      workoutPlanId: planId,
      workoutPlanWeekId: weekId,
      workoutPlanDayId: day2Id,
      planVersion: 1,
      workoutId: workoutBId,
    );
    await db.insert(WorkoutPlanWorkout.table, day2Workout.toMap());

    final todayWeekday = DateTime.now().weekday;
    final int expectedRelativeDay = todayWeekday == 1 ? 2 : 1;
    final int daysSinceStart = expectedRelativeDay - 1;
    final int createdAt =
        DateUtilities.getNowUtcUnix() - (daysSinceStart * 24 * 60 * 60);

    final record = WorkoutPlanRecord(
      workoutPlanId: planId,
      workoutPlanVersion: 1,
      status: ProgressStatus.inProgress,
      startedAt: createdAt,
      currentWeek: 1,
      currentDay: expectedRelativeDay,
      currentWorkoutPosition: 1,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    await db.insert(WorkoutPlanRecord.table, record.toMap());

    final cubit = WorkoutPlanRecordCubit();
    await cubit.getOrCreateActivePlanRecord(planId);

    final todaysWorkouts = cubit.state.currentPlanRecord.todaysWorkouts;
    expect(todaysWorkouts, isNotEmpty);

    final expectedName = expectedRelativeDay == 1 ? 'relative-a' : 'relative-b';
    expect(todaysWorkouts.first.name.startsWith(expectedName), isTrue);

    await cubit.close();
  });
}
