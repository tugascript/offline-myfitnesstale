import 'package:flutter/foundation.dart';

import '../../../models/enums.dart';
import '../../../services/dtos/workout_plan_day_dto.dart';
import '../../../services/dtos/workout_plan_week_dto.dart';
import '../../../services/dtos/workout_plan_workout_dto.dart';

class WorkoutPlanWorkoutEditorData {
  final String internalId;
  final int? id;
  int? workoutId;
  String? workoutName;
  WorkoutTimeOfDay? timeOfDay;

  WorkoutPlanWorkoutEditorData({
    String? internalId,
    this.id,
    this.workoutId,
    this.workoutName,
    this.timeOfDay,
  }) : internalId = internalId ?? UniqueKey().toString();

  factory WorkoutPlanWorkoutEditorData.fromDto(WorkoutPlanWorkoutDto dto) {
    return WorkoutPlanWorkoutEditorData(
      id: dto.id,
      workoutId: dto.workoutId,
      workoutName: dto.workout?.name,
      timeOfDay: dto.timeOfDay,
    );
  }

  WorkoutPlanWorkoutEditorData copy() {
    return WorkoutPlanWorkoutEditorData(
      internalId: internalId,
      id: id,
      workoutId: workoutId,
      workoutName: workoutName,
      timeOfDay: timeOfDay,
    );
  }
}

class WorkoutPlanDayEditorData {
  final String internalId;
  final int? id;
  int day;
  bool isRestDay;
  List<WorkoutPlanWorkoutEditorData> workouts;

  WorkoutPlanDayEditorData({
    String? internalId,
    this.id,
    required this.day,
    required this.isRestDay,
    required this.workouts,
  }) : internalId = internalId ?? UniqueKey().toString();

  factory WorkoutPlanDayEditorData.fromDto(WorkoutPlanDayDto dto) {
    return WorkoutPlanDayEditorData(
      id: dto.id,
      day: dto.day,
      isRestDay: dto.isRestDay,
      workouts: (dto.planWorkouts ?? [])
          .map(WorkoutPlanWorkoutEditorData.fromDto)
          .toList(),
    );
  }

  WorkoutPlanDayEditorData copy() {
    return WorkoutPlanDayEditorData(
      internalId: internalId,
      id: id,
      day: day,
      isRestDay: isRestDay,
      workouts: workouts.map((w) => w.copy()).toList(),
    );
  }
}

class WorkoutPlanWeekEditorData {
  final String internalId;
  final int? id;
  int startWeek;
  int endWeek;
  WorkoutPhase? phase;
  List<WorkoutPlanDayEditorData> days;

  WorkoutPlanWeekEditorData({
    String? internalId,
    this.id,
    required this.startWeek,
    required this.endWeek,
    this.phase,
    required this.days,
  }) : internalId = internalId ?? UniqueKey().toString();

  factory WorkoutPlanWeekEditorData.fromDto(WorkoutPlanWeekDto dto) {
    return WorkoutPlanWeekEditorData(
      id: dto.id,
      startWeek: dto.startWeek,
      endWeek: dto.endWeek,
      phase: dto.phase,
      days: (dto.days ?? []).map(WorkoutPlanDayEditorData.fromDto).toList(),
    );
  }

  WorkoutPlanWeekEditorData copy() {
    return WorkoutPlanWeekEditorData(
      internalId: internalId,
      id: id,
      startWeek: startWeek,
      endWeek: endWeek,
      phase: phase,
      days: days.map((d) => d.copy()).toList(),
    );
  }
}
