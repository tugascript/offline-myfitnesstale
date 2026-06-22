import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../services/dtos/workout_dto.dart';
import '../../services/dtos/workout_plan_dto.dart';
import '../../services/dtos/workout_plan_record_dto.dart';
import 'common_state.dart';

final class WorkoutPlanRecordPagination extends Equatable {
  final int? workoutPlanId;
  final ProgressStatus? progressStatus;
  final int limit;
  final int offset;
  final int total;

  const WorkoutPlanRecordPagination({
    this.workoutPlanId,
    this.progressStatus,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory WorkoutPlanRecordPagination.initial() {
    return const WorkoutPlanRecordPagination(
      limit: 20,
      offset: 0,
      total: 0,
    );
  }

  WorkoutPlanRecordPagination copyWith({
    int? workoutPlanId,
    ProgressStatus? progressStatus,
    int? limit,
    int? offset,
    int? total,
  }) {
    return WorkoutPlanRecordPagination(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [limit, offset, total];
}

final class CurrentWorkoutPlanRecordState extends Equatable {
  final WorkoutPlanRecordDto? currentPlanRecord;
  final WorkoutPlanDto? workoutPlan;
  final List<WorkoutDto> todaysWorkouts;
  final int currentWeek;
  final int currentDay;
  final int workoutIndex;
  final int completedWorkouts;
  final int totalWorkouts;

  const CurrentWorkoutPlanRecordState({
    this.currentPlanRecord,
    this.workoutPlan,
    required this.todaysWorkouts,
    required this.currentWeek,
    required this.currentDay,
    required this.workoutIndex,
    required this.completedWorkouts,
    required this.totalWorkouts,
  });

  factory CurrentWorkoutPlanRecordState.initial() {
    return const CurrentWorkoutPlanRecordState(
      todaysWorkouts: [],
      currentWeek: 0,
      currentDay: 0,
      workoutIndex: 0,
      completedWorkouts: 0,
      totalWorkouts: 0,
    );
  }

  CurrentWorkoutPlanRecordState copyWith({
    WorkoutPlanRecordDto? currentPlanRecord,
    WorkoutPlanDto? workoutPlan,
    List<WorkoutDto>? todaysWorkouts,
    int? currentWeek,
    int? currentDay,
    int? workoutIndex,
    int? completedWorkouts,
    int? totalWorkouts,
  }) {
    return CurrentWorkoutPlanRecordState(
      currentPlanRecord: currentPlanRecord ?? this.currentPlanRecord,
      workoutPlan: workoutPlan ?? this.workoutPlan,
      todaysWorkouts: todaysWorkouts ?? this.todaysWorkouts,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      workoutIndex: workoutIndex ?? this.workoutIndex,
      completedWorkouts: completedWorkouts ?? this.completedWorkouts,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
    );
  }

  @override
  List<Object?> get props => [
        currentPlanRecord,
        workoutPlan,
        todaysWorkouts,
        currentWeek,
        currentDay,
        workoutIndex,
        completedWorkouts,
        totalWorkouts,
      ];
}

final class WorkoutPlanRecordState extends Equatable {
  final CurrentWorkoutPlanRecordState currentPlanRecord;
  final List<WorkoutPlanRecordDto> planRecords;
  final WorkoutPlanRecordPagination pagination;
  final bool isLoading;
  final ErrorState? error;

  const WorkoutPlanRecordState({
    required this.currentPlanRecord,
    required this.planRecords,
    required this.pagination,
    required this.isLoading,
    this.error,
  });

  factory WorkoutPlanRecordState.initial() {
    return WorkoutPlanRecordState(
      currentPlanRecord: CurrentWorkoutPlanRecordState.initial(),
      planRecords: const [],
      pagination: WorkoutPlanRecordPagination.initial(),
      isLoading: false,
    );
  }

  WorkoutPlanRecordState copyWith({
    CurrentWorkoutPlanRecordState? currentPlanRecord,
    List<WorkoutPlanRecordDto>? planRecords,
    WorkoutPlanRecordPagination? pagination,
    bool? isLoading,
    ErrorState? error,
  }) {
    return WorkoutPlanRecordState(
      currentPlanRecord: currentPlanRecord ?? this.currentPlanRecord,
      planRecords: planRecords ?? this.planRecords,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        currentPlanRecord,
        planRecords,
        pagination,
        isLoading,
        error,
      ];
}
