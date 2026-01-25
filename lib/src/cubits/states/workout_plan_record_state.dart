import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
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

final class WorkoutPlanRecordState extends Equatable {
  final WorkoutPlanRecordDto? currentPlanRecord;
  final List<WorkoutPlanRecordDto> planRecords;
  final WorkoutPlanRecordPagination pagination;
  final bool isLoading;
  final ErrorState? error;

  const WorkoutPlanRecordState({
    this.currentPlanRecord,
    required this.planRecords,
    required this.pagination,
    required this.isLoading,
    this.error,
  });

  factory WorkoutPlanRecordState.initial() {
    return WorkoutPlanRecordState(
      planRecords: const [],
      pagination: WorkoutPlanRecordPagination.initial(),
      isLoading: false,
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
