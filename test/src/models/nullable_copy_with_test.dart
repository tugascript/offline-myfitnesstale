import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/common/nullable.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/equipment_model.dart';
import 'package:myfitnesstale/src/models/exercise_model.dart';
import 'package:myfitnesstale/src/models/exercise_record_model.dart';
import 'package:myfitnesstale/src/models/food_model.dart';
import 'package:myfitnesstale/src/models/weight_goal_model.dart';
import 'package:myfitnesstale/src/models/weight_record_model.dart';
import 'package:myfitnesstale/src/models/workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_day_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_day_record_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_record_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_week_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_week_record_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_workout_model.dart';
import 'package:myfitnesstale/src/models/workout_plan_workout_record_model.dart';
import 'package:myfitnesstale/src/models/workout_record_model.dart';
import 'package:myfitnesstale/src/models/workout_set_exercise_model.dart';
import 'package:myfitnesstale/src/models/workout_set_exercise_option_model.dart';
import 'package:myfitnesstale/src/models/workout_set_exercise_record_model.dart';
import 'package:myfitnesstale/src/models/workout_set_model.dart';
import 'package:myfitnesstale/src/models/workout_set_record_model.dart';
import 'package:myfitnesstale/src/services/dtos/equipment_dto.dart';
import 'package:myfitnesstale/src/services/dtos/exercise_dto.dart';
import 'package:myfitnesstale/src/services/dtos/exercise_record_dto.dart';
import 'package:myfitnesstale/src/services/dtos/strength_goal_dto.dart';
import 'package:myfitnesstale/src/services/dtos/weight_goal_dto.dart';
import 'package:myfitnesstale/src/services/dtos/weight_record_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_day_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_day_record_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_record_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_week_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_week_record_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_workout_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_plan_workout_record_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_record_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_set_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_set_exercise_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_set_exercise_option_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_set_exercise_record_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_set_record_dto.dart';

void main() {
  group('nullable copyWith fields', () {
    test('Micronutrients can preserve, clear, and replace nullable values', () {
      const micronutrients = Micronutrients(potassiumMg: 250, zincMg: 3);

      expect(micronutrients.copyWith().potassiumMg, 250);
      expect(
        micronutrients.copyWith(potassiumMg: const Nullable(null)).potassiumMg,
        isNull,
      );
      expect(micronutrients.copyWith(zincMg: const Nullable(5)).zincMg, 5);
    });

    test('Food can preserve, clear, and replace nullable text fields', () {
      final food = Food.create(
        name: 'Oats',
        category: FoodCategory.grainsAndCereals,
        brand: 'Mill',
        servingSizeBaseGrams: 100,
        caloriesBase: 380,
        proteinBase: 13,
        carbsBase: 68,
        fatBase: 7,
      );

      expect(food.copyWith().brand, 'Mill');
      expect(food.copyWith(brand: const Nullable(null)).brand, isNull);
      expect(food.copyWith(brand: const Nullable('Farm')).brand, 'Farm');
      expect(food.copyWith(id: const Nullable(12)).id, 12);
      expect(food.copyWith(id: const Nullable(null)).id, isNull);
    });

    test('StrengthGoalDto can clear its completion date', () {
      final completedAt = DateTime(2026, 10, 12);
      final goal = StrengthGoalDto(
        id: 1,
        name: 'Bench press',
        targetReps: 5,
        targetWeight: 80000,
        targetMaxStrength: 90000,
        exerciseId: 2,
        status: ProgressStatus.completed,
        startDate: DateTime(2026, 10, 1),
        completedAt: completedAt,
      );

      expect(goal.copyWith().completedAt, completedAt);
      expect(
        goal.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );
      expect(
        goal
            .copyWith(completedAt: Nullable(DateTime(2026, 10, 11)))
            .completedAt,
        DateTime(2026, 10, 11),
      );
    });

    test('WeightRecord and WeightRecordDto can clear nullable fields', () {
      final record = WeightRecord.create(
        weight: 80000,
        recordDate: 1700000000,
        fatPercentage: 1800,
        pictureUri: 'file:///photo.jpg',
        weightGoalId: 3,
      );

      expect(record.copyWith().fatPercentage, 1800);
      expect(record.copyWith().pictureUri, 'file:///photo.jpg');
      expect(record.copyWith().weightGoalId, 3);
      expect(
        record.copyWith(fatPercentage: const Nullable(null)).fatPercentage,
        isNull,
      );
      expect(
        record.copyWith(pictureUri: const Nullable(null)).pictureUri,
        isNull,
      );
      expect(
        record.copyWith(weightGoalId: const Nullable(null)).weightGoalId,
        isNull,
      );

      final dto = WeightRecordDto.fromModel(
        record.copyWith(id: const Nullable(1)),
      );
      expect(dto.copyWith().fatPercentage, 1800);
      expect(
        dto.copyWith(fatPercentage: const Nullable(null)).fatPercentage,
        isNull,
      );
      expect(dto.copyWith(pictureUri: const Nullable(null)).pictureUri, isNull);
    });

    test('WeightGoal and WeightGoalDto can clear nullable fields', () {
      final goal = WeightGoal.create(
        targetWeight: 75000,
        targetFatPercentage: 1500,
        startDate: 1700000000,
        phase: WeightGoalPhase.cut,
        status: ProgressStatus.completed,
        completedAt: 1700086400,
      );

      expect(goal.copyWith().targetFatPercentage, 1500);
      expect(goal.copyWith().completedAt, 1700086400);
      expect(
        goal
            .copyWith(targetFatPercentage: const Nullable(null))
            .targetFatPercentage,
        isNull,
      );
      expect(
        goal.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );

      final dto = WeightGoalDto.fromModel(goal.copyWith(id: const Nullable(1)));
      expect(dto.copyWith().targetFatPercentage, 1500);
      expect(
        dto
            .copyWith(targetFatPercentage: const Nullable(null))
            .targetFatPercentage,
        isNull,
      );
      expect(
        dto.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );
    });

    test('Equipment, Exercise, ExerciseRecord and their DTOs can clear nullable fields', () {
      const pic = PictureData(
        uri: 'file:///pic.jpg',
        storage: PictureStorage.files,
      );
      const vid = VideoData(
        uri: 'https://youtu.be/1',
        platform: VideoPlatform.youtube,
      );

      final equipment = Equipment.create(
        name: 'Barbell',
        picture: pic,
        isFavorite: true,
      ).copyWith(id: const Nullable(1));
      expect(equipment.copyWith().picture, pic);
      expect(equipment.copyWith(picture: const Nullable(null)).picture, isNull);
      final equipmentDto = EquipmentDto.fromModel(equipment);
      expect(equipmentDto.copyWith().picture, isNotNull);
      expect(
        equipmentDto.copyWith(picture: const Nullable(null)).picture,
        isNull,
      );

      final exercise = Exercise.create(
        name: 'Bench Press',
        muscleGroup: MuscleGroup.push,
        muscles: const TargetMuscles(primary: {}, secondary: {}),
        description: 'Flat bench',
        picture: pic,
        video: vid,
        difficulty: Difficulty.intermediate,
      ).copyWith(id: const Nullable(2));
      expect(exercise.copyWith().description, 'Flat bench');
      expect(
        exercise.copyWith(description: const Nullable(null)).description,
        isNull,
      );
      expect(exercise.copyWith(picture: const Nullable(null)).picture, isNull);
      expect(exercise.copyWith(video: const Nullable(null)).video, isNull);
      expect(
        exercise.copyWith(difficulty: const Nullable(null)).difficulty,
        isNull,
      );

      final exerciseDto = ExerciseDto.fromModel(
        exercise,
        equipments: [equipmentDto],
      );
      expect(exerciseDto.copyWith().difficulty, Difficulty.intermediate);
      expect(
        exerciseDto.copyWith(difficulty: const Nullable(null)).difficulty,
        isNull,
      );
      expect(
        exerciseDto.copyWith(equipments: const Nullable(null)).equipments,
        isNull,
      );

      final record = ExerciseRecord.create(
        exerciseId: 2,
        weight: 80000,
        reps: 5,
        recordDate: 1700000000,
        picture: pic,
        video: vid,
      ).copyWith(id: const Nullable(3));
      expect(record.copyWith().picture, pic);
      expect(record.copyWith(picture: const Nullable(null)).picture, isNull);
      expect(record.copyWith(video: const Nullable(null)).video, isNull);

      final recordDto = ExerciseRecordDto.fromModel(
        record,
        exercise: exerciseDto,
      );
      expect(recordDto.copyWith().exercise, exerciseDto);
      expect(
        recordDto.copyWith(exercise: const Nullable(null)).exercise,
        isNull,
      );
      expect(recordDto.copyWith(picture: const Nullable(null)).picture, isNull);
    });

    test('Workout and WorkoutRecord related models and DTOs support Nullable copyWith', () {
      const pic = PictureData(
        uri: 'file:///pic.jpg',
        storage: PictureStorage.files,
      );
      const vid = VideoData(
        uri: 'https://youtu.be/1',
        platform: VideoPlatform.youtube,
      );

      final workout = Workout.create(
        name: 'Push Day',
        difficulty: Difficulty.intermediate,
        description: 'Chest focus',
        picture: pic,
        video: vid,
        phase: WorkoutPhase.maxStrength,
      ).copyWith(id: const Nullable(1));
      expect(workout.copyWith().description, 'Chest focus');
      expect(workout.copyWith().phase, WorkoutPhase.maxStrength);
      expect(
        workout.copyWith(description: const Nullable(null)).description,
        isNull,
      );
      expect(workout.copyWith(picture: const Nullable(null)).picture, isNull);
      expect(workout.copyWith(video: const Nullable(null)).video, isNull);
      expect(workout.copyWith(phase: const Nullable(null)).phase, isNull);

      final workoutSet = WorkoutSet.create(
        workoutId: 1,
        workoutVersion: 1,
        position: 1,
        setType: WorkoutSetType.standard,
        minSets: 3,
        maxSets: 4,
        recommendedRestSecs: 90,
        maxRestSecs: 120,
      ).copyWith(id: const Nullable(2));
      expect(workoutSet.copyWith().maxSets, 4);
      expect(workoutSet.copyWith().maxRestSecs, 120);
      expect(
        workoutSet.copyWith(maxSets: const Nullable(null)).maxSets,
        isNull,
      );
      expect(
        workoutSet.copyWith(maxRestSecs: const Nullable(null)).maxRestSecs,
        isNull,
      );

      const diff = WorkoutSetExerciseDifficulty(
        type: WorkoutSetExerciseDifficultyType.rpe,
        value: 8,
      );
      final setExercise = WorkoutSetExercise.create(
        workoutId: 1,
        workoutVersion: 1,
        workoutSetId: 2,
        exerciseId: 10,
        position: 1,
        minReps: 8,
        maxReps: 12,
        difficulty: diff,
      ).copyWith(id: const Nullable(3));
      expect(setExercise.copyWith().maxReps, 12);
      expect(setExercise.copyWith().difficulty, diff);
      expect(
        setExercise.copyWith(maxReps: const Nullable(null)).maxReps,
        isNull,
      );
      expect(
        setExercise.copyWith(difficulty: const Nullable(null)).difficulty,
        isNull,
      );

      final option = WorkoutSetExerciseOption.create(
        workoutId: 1,
        workoutVersion: 1,
        workoutSetId: 2,
        workoutSetExerciseId: 3,
        exerciseId: 11,
        position: 1,
      ).copyWith(id: const Nullable(4));
      expect(option.copyWith().id, 4);
      expect(option.copyWith(id: const Nullable(null)).id, isNull);

      final optionDto = WorkoutSetExerciseOptionDto.fromModel(option);
      final setExerciseDto = WorkoutSetExerciseDto.fromModel(
        setExercise,
        options: [optionDto],
      );
      expect(setExerciseDto.copyWith().maxReps, 12);
      expect(
        setExerciseDto.copyWith(maxReps: const Nullable(null)).maxReps,
        isNull,
      );
      expect(
        setExerciseDto.copyWith(difficulty: const Nullable(null)).difficulty,
        isNull,
      );
      expect(
        setExerciseDto.copyWith(options: const Nullable(null)).options,
        isNull,
      );

      final setDto = WorkoutSetDto.fromModel(
        workoutSet,
        exercises: [setExerciseDto],
      );
      expect(setDto.copyWith(maxSets: const Nullable(null)).maxSets, isNull);
      expect(
        setDto.copyWith(maxRestSecs: const Nullable(null)).maxRestSecs,
        isNull,
      );
      expect(
        setDto.copyWith(exercises: const Nullable(null)).exercises,
        isNull,
      );

      final workoutDto = WorkoutDto.fromModel(workout, sets: [setDto]);
      expect(workoutDto.phase, WorkoutPhase.maxStrength);
      expect(workoutDto.copyWith().phase, WorkoutPhase.maxStrength);
      expect(
        workoutDto.copyWith(description: const Nullable(null)).description,
        isNull,
      );
      expect(workoutDto.copyWith(phase: const Nullable(null)).phase, isNull);
      expect(workoutDto.copyWith(sets: const Nullable(null)).sets, isNull);

      final workoutRecord = WorkoutRecord.create(
        workoutId: 1,
        version: 1,
        startedAt: 1700000000,
        completedAt: 1700003600,
        droppedAt: 1700001800,
      ).copyWith(id: const Nullable(5));
      expect(workoutRecord.copyWith().completedAt, 1700003600);
      expect(workoutRecord.copyWith().droppedAt, 1700001800);
      expect(
        workoutRecord.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );
      expect(
        workoutRecord.copyWith(droppedAt: const Nullable(null)).droppedAt,
        isNull,
      );

      final setRecord = WorkoutSetRecord.create(
        workoutSetId: 2,
        workoutRecordId: 5,
        setNumber: 1,
        startedAt: 1700000000,
        totalRestSecs: 90,
        completedAt: 1700000100,
      ).copyWith(id: const Nullable(6));
      expect(setRecord.copyWith().totalRestSecs, 90);
      expect(setRecord.copyWith().completedAt, 1700000100);
      expect(
        setRecord.copyWith(totalRestSecs: const Nullable(null)).totalRestSecs,
        isNull,
      );
      expect(
        setRecord.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );

      final exerciseRecord = WorkoutSetExerciseRecord.create(
        workoutSetExerciseId: 3,
        workoutRecordId: 5,
        workoutSetRecordId: 6,
        exerciseId: 10,
        position: 1,
        reps: 10,
        weightGrams: 60000,
        difficulty: diff,
      ).copyWith(id: const Nullable(7));
      expect(exerciseRecord.copyWith().id, 7);

      final exerciseRecordDto = WorkoutSetExerciseRecordDto.fromModel(
        exerciseRecord,
      );
      final setRecordDto = WorkoutSetRecordDto.fromModel(
        setRecord,
        setExerciseRecords: [exerciseRecordDto],
      );
      expect(
        setRecordDto
            .copyWith(totalRestSecs: const Nullable(null))
            .totalRestSecs,
        isNull,
      );
      expect(
        setRecordDto.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );

      final workoutRecordDto = WorkoutRecordDto.fromModel(
        workoutRecord,
        setRecords: [setRecordDto],
      );
      expect(
        workoutRecordDto
            .copyWith(completedAt: const Nullable(null))
            .completedAt,
        isNull,
      );
      expect(
        workoutRecordDto.copyWith(setRecords: const Nullable(null)).setRecords,
        isNull,
      );
    });

    test('WorkoutPlan and WorkoutPlanRecord related models and DTOs support Nullable copyWith', () {
      const pic = PictureData(
        uri: 'file:///pic.jpg',
        storage: PictureStorage.files,
      );

      final plan = WorkoutPlan.create(
        name: 'Strength Block',
        description: '4 week block',
        picture: pic,
        difficulty: Difficulty.intermediate,
        isFavorite: true,
      ).copyWith(id: const Nullable(1));
      expect(plan.copyWith().description, '4 week block');
      expect(
        plan.copyWith(description: const Nullable(null)).description,
        isNull,
      );
      expect(plan.copyWith(picture: const Nullable(null)).picture, isNull);

      final week = WorkoutPlanWeek.create(
        workoutPlanId: 1,
        planVersion: 1,
        startWeek: 1,
        endWeek: 4,
        phase: WorkoutPhase.maxStrength,
      ).copyWith(id: const Nullable(2));
      expect(week.copyWith().phase, WorkoutPhase.maxStrength);
      expect(week.copyWith(phase: const Nullable(null)).phase, isNull);

      final day = WorkoutPlanDay.create(
        workoutPlanId: 1,
        planVersion: 1,
        workoutPlanWeekId: 2,
        day: 1,
      ).copyWith(id: const Nullable(3));
      expect(day.copyWith().id, 3);
      expect(day.copyWith(id: const Nullable(null)).id, isNull);

      final planWorkout = WorkoutPlanWorkout.create(
        workoutPlanId: 1,
        planVersion: 1,
        workoutPlanWeekId: 2,
        workoutPlanDayId: 3,
        workoutId: 10,
        position: 1,
        timeOfDay: WorkoutTimeOfDay.morning,
      ).copyWith(id: const Nullable(4));
      expect(planWorkout.copyWith().id, 4);
      expect(planWorkout.copyWith().timeOfDay, WorkoutTimeOfDay.morning);
      expect(
        planWorkout.copyWith(timeOfDay: const Nullable(null)).timeOfDay,
        isNull,
      );

      final planWorkoutDto = WorkoutPlanWorkoutDto.fromModel(planWorkout);
      expect(
        planWorkoutDto.copyWith(timeOfDay: const Nullable(null)).timeOfDay,
        isNull,
      );

      final dayDto = WorkoutPlanDayDto.fromModel(
        day,
        planWorkouts: [planWorkoutDto],
      );
      expect(
        dayDto.copyWith(planWorkouts: const Nullable(null)).planWorkouts,
        isNull,
      );

      final weekDto = WorkoutPlanWeekDto.fromModel(week, days: [dayDto]);
      expect(weekDto.copyWith().phase, WorkoutPhase.maxStrength);
      expect(weekDto.copyWith(phase: const Nullable(null)).phase, isNull);

      final planDto = WorkoutPlanDto.fromModel(plan, weeks: [weekDto]);
      expect(
        planDto.copyWith(description: const Nullable(null)).description,
        isNull,
      );
      expect(planDto.copyWith(weeks: const Nullable(null)).weeks, isNull);

      final planRecord = WorkoutPlanRecord.create(
        1,
        workoutPlanVersion: 1,
        status: ProgressStatus.completed,
        currentWeek: 1,
        currentDay: 1,
        currentWorkoutPosition: 1,
        startedAt: 1700000000,
        completedAt: 1700086400,
      ).copyWith(id: const Nullable(5));
      expect(planRecord.copyWith().completedAt, 1700086400);
      expect(
        planRecord.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );

      final weekRecord =
          WorkoutPlanWeekRecord.create(
            workoutPlanRecordId: 5,
            workoutPlanWeekId: 2,
            week: 1,
            status: ProgressStatus.completed,
          ).copyWith(
            id: const Nullable(6),
            completedAt: const Nullable(1700086400),
          );
      expect(weekRecord.copyWith().completedAt, 1700086400);
      expect(
        weekRecord.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );

      final dayRecord =
          WorkoutPlanDayRecord.create(
            workoutPlanRecordId: 5,
            workoutPlanWeekRecordId: 6,
            workoutPlanDayId: 3,
            status: ProgressStatus.completed,
          ).copyWith(
            id: const Nullable(7),
            completedAt: const Nullable(1700086400),
          );
      expect(dayRecord.copyWith().completedAt, 1700086400);
      expect(
        dayRecord.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );

      final workoutRecord =
          WorkoutPlanWorkoutRecord.create(
            workoutPlanRecordId: 5,
            workoutPlanWeekRecordId: 6,
            workoutPlanDayRecordId: 7,
            workoutPlanWorkoutId: 4,
            workoutRecordId: 99,
            position: 1,
            status: ProgressStatus.completed,
          ).copyWith(
            id: const Nullable(8),
            completedAt: const Nullable(1700086400),
          );
      expect(workoutRecord.copyWith().completedAt, 1700086400);
      expect(
        workoutRecord.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );

      final workoutRecordDto = WorkoutPlanWorkoutRecordDto.fromModel(
        workoutRecord,
      );
      expect(workoutRecordDto.copyWith().completedAt, isNotNull);
      expect(
        workoutRecordDto
            .copyWith(completedAt: const Nullable(null))
            .completedAt,
        isNull,
      );

      final dayRecordDto = WorkoutPlanDayRecordDto.fromModel(
        dayRecord,
        workouts: [workoutRecordDto],
      );
      expect(
        dayRecordDto.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );

      final weekRecordDto = WorkoutPlanWeekRecordDto.fromModel(
        weekRecord,
        days: [dayRecordDto],
      );
      expect(
        weekRecordDto.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );

      final planRecordDto = WorkoutPlanRecordDto.fromModel(
        planRecord,
        weeks: [weekRecordDto],
      );
      expect(
        planRecordDto.copyWith(completedAt: const Nullable(null)).completedAt,
        isNull,
      );
    });
  });
}
