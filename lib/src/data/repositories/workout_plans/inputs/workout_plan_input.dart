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

import '../../../../utils/nullable.dart';
import '../../../utils/json_data.dart';
import '../../../utils/enums.dart';
import '../../workouts/dtos/workout_dto.dart';

class WorkoutPlanInput {
  final String name;
  final Difficulty difficulty;
  final bool isFavorite;
  final int totalWeeks;
  final Nullable<String> description;
  final Nullable<PictureData> picture;
  final Nullable<VideoData> video;

  const WorkoutPlanInput({
    required this.name,
    required this.difficulty,
    this.isFavorite = false,
    this.totalWeeks = 0,
    this.description = const Nullable<String>(null),
    this.picture = const Nullable<PictureData>(null),
    this.video = const Nullable<VideoData>(null),
  });
}

class WorkoutPlanWeekInput {
  final int startWeek;
  final int endWeek;
  final Nullable<WorkoutPhase> phase;
  final WorkoutPlanWeekScheduleMode scheduleMode;

  const WorkoutPlanWeekInput({
    required this.startWeek,
    required this.endWeek,
    this.phase = const Nullable<WorkoutPhase>(null),
    this.scheduleMode = WorkoutPlanWeekScheduleMode.manual,
  });
}

class WorkoutPlanWorkoutInput {
  final int workoutId;
  final int? position;
  final Nullable<WorkoutTimeOfDay> timeOfDay;

  const WorkoutPlanWorkoutInput({
    required this.workoutId,
    this.position,
    this.timeOfDay = const Nullable<WorkoutTimeOfDay>(null),
  });
}

class WeekWorkoutInput {
  final int workoutId;
  final WorkoutTimeOfDay? timeOfDay;

  const WeekWorkoutInput({required this.workoutId, this.timeOfDay});
}

class WorkoutPlanWorkoutBatchCreateInput {
  final int workoutId;
  final WorkoutTimeOfDay? timeOfDay;

  const WorkoutPlanWorkoutBatchCreateInput({
    required this.workoutId,
    this.timeOfDay,
  });
}

class WorkoutPlanDayBatchCreateInput {
  final int day;
  final bool isRestDay;
  final List<WorkoutPlanWorkoutBatchCreateInput> workouts;

  const WorkoutPlanDayBatchCreateInput({
    required this.day,
    this.isRestDay = false,
    required this.workouts,
  });
}

class WorkoutPlanWeekBatchCreateInput {
  final int startWeek;
  final int endWeek;
  final WorkoutPhase? phase;
  final WorkoutPlanWeekScheduleMode scheduleMode;
  final List<WorkoutPlanDayBatchCreateInput> days;

  const WorkoutPlanWeekBatchCreateInput({
    required this.startWeek,
    required this.endWeek,
    this.phase,
    this.scheduleMode = WorkoutPlanWeekScheduleMode.manual,
    required this.days,
  });
}

class WorkoutPlanWorkoutRegistrationInput {
  final WorkoutDto workout;
  final WorkoutTimeOfDay timeOfDay;

  const WorkoutPlanWorkoutRegistrationInput({
    required this.workout,
    required this.timeOfDay,
  });
}

class WorkoutPlanDayRegistrationInput {
  final bool isRestDay;
  final List<WorkoutPlanWorkoutRegistrationInput> workouts;

  const WorkoutPlanDayRegistrationInput({
    this.isRestDay = false,
    required this.workouts,
  });
}

class WorkoutPlanWeekRegistrationInput {
  final int startWeek;
  final int endWeek;
  final WorkoutPhase phase;
  final List<WorkoutPlanDayRegistrationInput> days;

  const WorkoutPlanWeekRegistrationInput({
    required this.startWeek,
    required this.endWeek,
    required this.phase,
    required this.days,
  });
}

class WorkoutPlanRegistrationInput {
  final String name;
  final String description;
  final PictureData? picture;
  final VideoData? video;
  final Difficulty difficulty;
  final List<WorkoutPlanWeekRegistrationInput> weeks;

  const WorkoutPlanRegistrationInput({
    required this.name,
    required this.description,
    this.picture,
    this.video,
    required this.difficulty,
    required this.weeks,
  });
}
