import 'package:equatable/equatable.dart';

import '../../services/dtos/workout_record_dto.dart';
import 'common_state.dart';

final class WorkoutRecordPagination extends Equatable {
  final int? workoutId;
  final int limit;
  final int offset;
  final int total;

  const WorkoutRecordPagination({
    this.workoutId,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory WorkoutRecordPagination.initial() {
    return const WorkoutRecordPagination(
      limit: 20,
      offset: 0,
      total: 0,
    );
  }

  WorkoutRecordPagination copyWith({
    int? workoutId,
    int? limit,
    int? offset,
    int? total,
  }) {
    return WorkoutRecordPagination(
      workoutId: workoutId ?? this.workoutId,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
        workoutId,
        limit,
        offset,
        total,
      ];
}

final class WorkoutRecordState extends Equatable {
  final List<WorkoutRecordDto> workoutRecords;
  final WorkoutRecordDto? currentWorkoutRecord;
  final WorkoutRecordDto? selectedWorkoutRecord;
  final WorkoutRecordPagination pagination;
  final bool isLoading;
  final ErrorState? error;

  const WorkoutRecordState({
    required this.workoutRecords,
    this.currentWorkoutRecord,
    this.selectedWorkoutRecord,
    required this.pagination,
    required this.isLoading,
    this.error,
  });

  factory WorkoutRecordState.initial() {
    return WorkoutRecordState(
      workoutRecords: [],
      pagination: WorkoutRecordPagination.initial(),
      isLoading: false,
    );
  }

  WorkoutRecordState copyWith({
    List<WorkoutRecordDto>? workoutRecords,
    WorkoutRecordDto? currentWorkoutRecord,
    WorkoutRecordDto? selectedWorkoutRecord,
    WorkoutRecordPagination? pagination,
    bool? isLoading,
    ErrorState? error,
  }) {
    return WorkoutRecordState(
      workoutRecords: workoutRecords ?? this.workoutRecords,
      currentWorkoutRecord: currentWorkoutRecord ?? this.currentWorkoutRecord,
      selectedWorkoutRecord:
          selectedWorkoutRecord ?? this.selectedWorkoutRecord,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        workoutRecords,
        currentWorkoutRecord,
        selectedWorkoutRecord,
        pagination,
        isLoading,
        error,
      ];
}
