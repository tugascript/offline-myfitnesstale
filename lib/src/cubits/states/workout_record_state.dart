import 'package:equatable/equatable.dart';

import '../../models/workout_record_model.dart';

final class WorkoutRecordPagination extends Equatable {
  final int limit;
  final int offset;

  const WorkoutRecordPagination({
    required this.limit,
    required this.offset,
  });

  factory WorkoutRecordPagination.initial() {
    return const WorkoutRecordPagination(
      limit: 20,
      offset: 0,
    );
  }

  WorkoutRecordPagination copyWith({int? limit, int? offset}) {
    return WorkoutRecordPagination(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [
        limit,
        offset,
      ];
}

final class WorkoutRecordState extends Equatable {
  final List<WorkoutRecord> workoutRecords;
  final WorkoutRecord? selectedWorkoutRecord;
  final WorkoutRecordPagination pagination;
  final int workoutRecordTotal;
  final bool isLoading;
  final String? error;

  const WorkoutRecordState({
    required this.workoutRecords,
    this.selectedWorkoutRecord,
    required this.pagination,
    required this.isLoading,
    required this.workoutRecordTotal,
    this.error,
  });

  factory WorkoutRecordState.initial() {
    return WorkoutRecordState(
      workoutRecords: [],
      pagination: WorkoutRecordPagination.initial(),
      isLoading: false,
      workoutRecordTotal: 0,
    );
  }

  WorkoutRecordState copyWith({
    List<WorkoutRecord>? workoutRecords,
    WorkoutRecord? selectedWorkoutRecord,
    WorkoutRecordPagination? pagination,
    bool? isLoading,
    String? error,
    int? workoutRecordTotal,
  }) {
    return WorkoutRecordState(
      workoutRecords: workoutRecords ?? this.workoutRecords,
      selectedWorkoutRecord:
          selectedWorkoutRecord ?? this.selectedWorkoutRecord,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      workoutRecordTotal: workoutRecordTotal ?? this.workoutRecordTotal,
    );
  }

  @override
  List<Object?> get props => [
        workoutRecords,
        selectedWorkoutRecord,
        pagination,
        workoutRecordTotal,
        isLoading,
        error,
      ];
}
