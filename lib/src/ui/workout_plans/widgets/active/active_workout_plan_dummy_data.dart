// Copyright (C) 2026 afonsobarracha
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

import '../../view_models/states/workout_plan_record_state.dart';
import '../../../../data/utils/json_data.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_record_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_week_dto.dart';
import '../../../../data/repositories/workout_plans/dtos/workout_plan_workout_dto.dart';

class ActiveWorkoutPlanDummyData {
  static CurrentWorkoutPlanRecordState get dummyState {
    final now = DateTime.now();

    final dummyWorkout = WorkoutDto(
      id: 0,
      name: 'Loading Workout Name...',
      muscleGroups: const {},
      muscles: const TargetMuscles(primary: {}, secondary: {}),
      difficulty: Difficulty.beginner,
      version: 1,
      isFavorite: false,
      totalSets: 3,
      totalReps: 30,
      editorType: EditorType.advanced,
      createdBy: CreatedBy.system,
    );

    final dummyPlanWorkout = WorkoutPlanWorkoutDto(
      id: 0,
      planVersion: 1,
      position: 1,
      workoutId: 0,
      workout: dummyWorkout,
    );

    final dummyDays = List.generate(7, (index) {
      final dayNum = index + 1;
      final isRest = dayNum % 3 == 0;
      return WorkoutPlanDayDto(
        id: 0,
        planVersion: 1,
        day: dayNum,
        totalWorkouts: isRest ? 0 : 1,
        isRestDay: isRest,
        planWorkouts: isRest ? [] : [dummyPlanWorkout],
      );
    });

    final dummyWeeks = List.generate(2, (index) {
      return WorkoutPlanWeekDto(
        id: 0,
        planVersion: 1,
        startWeek: index + 1,
        endWeek: index + 1,
        totalDays: 7,
        totalWorkouts: 4,
        scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
        days: dummyDays,
      );
    });

    final dummyPlan = WorkoutPlanDto(
      id: 0,
      name: 'Loading Plan...',
      description: 'Loading description...',
      currentVersion: 1,
      totalWeeks: 2,
      totalDays: 14,
      totalWorkouts: 8,
      difficulty: Difficulty.beginner,
      isFavorite: false,
      createdBy: CreatedBy.system,
      weeks: dummyWeeks,
    );

    final dummyRecord = WorkoutPlanRecordDto(
      id: 0,
      workoutPlanId: 0,
      workoutPlanVersion: 1,
      status: ProgressStatus.inProgress,
      startedAt: now.subtract(const Duration(days: 2)), // 2 days ago
      currentWeek: 1,
      currentDay: 1,
      currentWorkoutPosition: 1,
    );

    return CurrentWorkoutPlanRecordState(
      currentPlanRecord: dummyRecord,
      workoutPlan: dummyPlan,
      todaysWorkouts: [dummyWorkout],
      currentWeek: 1,
      currentDay: 1,
      workoutIndex: 1,
      completedWorkouts: 2,
      totalWorkouts: 8,
    );
  }
}
