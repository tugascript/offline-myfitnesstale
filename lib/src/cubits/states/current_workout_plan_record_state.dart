import 'package:equatable/equatable.dart';

import '../../models/current_workout_plan_record_model.dart';
import '../../models/workout_model.dart';
import '../../models/workout_plan_model.dart';
import '../../models/workout_plan_record.dart';

final class CurrentWorkoutPlanRecordState extends Equatable {
  final CurrentWorkoutPlanRecord? currentPlanRecord;
  final WorkoutPlan? workoutPlan;
  final WorkoutPlanRecord? workoutPlanRecord;
  final List<Workout> todaysWorkouts;
  final double progressPercentage;
  final int completedWorkouts;
  final int totalWorkouts;
  final bool isLoading;
  final String? error;

  const CurrentWorkoutPlanRecordState({
    this.currentPlanRecord,
    this.workoutPlan,
    this.workoutPlanRecord,
    required this.todaysWorkouts,
    required this.progressPercentage,
    required this.completedWorkouts,
    required this.totalWorkouts,
    required this.isLoading,
    this.error,
  });

  factory CurrentWorkoutPlanRecordState.initial() {
    return const CurrentWorkoutPlanRecordState(
      todaysWorkouts: [],
      progressPercentage: 0.0,
      completedWorkouts: 0,
      totalWorkouts: 0,
      isLoading: false,
    );
  }

  CurrentWorkoutPlanRecordState copyWith({
    CurrentWorkoutPlanRecord? currentPlanRecord,
    WorkoutPlan? workoutPlan,
    WorkoutPlanRecord? workoutPlanRecord,
    List<Workout>? todaysWorkouts,
    double? progressPercentage,
    int? completedWorkouts,
    int? totalWorkouts,
    bool? isLoading,
    String? error,
  }) {
    return CurrentWorkoutPlanRecordState(
      currentPlanRecord: currentPlanRecord ?? this.currentPlanRecord,
      workoutPlan: workoutPlan ?? this.workoutPlan,
      workoutPlanRecord: workoutPlanRecord ?? this.workoutPlanRecord,
      todaysWorkouts: todaysWorkouts ?? this.todaysWorkouts,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      completedWorkouts: completedWorkouts ?? this.completedWorkouts,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        currentPlanRecord,
        workoutPlan,
        workoutPlanRecord,
        todaysWorkouts.length,
        progressPercentage,
        completedWorkouts,
        totalWorkouts,
        isLoading,
        error,
      ];
}
