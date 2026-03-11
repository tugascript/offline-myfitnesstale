import 'package:equatable/equatable.dart';

import '../../common/nullable.dart';
import '../../services/dtos/exercise_record_dto.dart';
import 'common_state.dart';

final class ExerciseRecordPagination extends Equatable {
  final int? exerciseId;
  final (DateTime start, DateTime end)? dateRange;
  final int limit;
  final int offset;
  final int total;

  const ExerciseRecordPagination({
    this.exerciseId,
    this.dateRange,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory ExerciseRecordPagination.initial() {
    return const ExerciseRecordPagination(
      limit: 10,
      offset: 0,
      total: 0,
    );
  }

  ExerciseRecordPagination copyWith({
    Nullable<int>? exerciseId,
    Nullable<(DateTime start, DateTime end)>? dateRange,
    int? limit,
    int? offset,
    int? total,
  }) {
    return ExerciseRecordPagination(
      exerciseId: exerciseId != null ? exerciseId.value : this.exerciseId,
      dateRange: dateRange != null ? dateRange.value : this.dateRange,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [exerciseId, dateRange, limit, offset, total];
}

final class ExerciseRecordState extends Equatable {
  final List<ExerciseRecordDto> exerciseRecords;
  final ExerciseRecordDto? selectedExerciseRecord;
  final ExerciseRecordDto? latestExerciseRecord;
  final ExerciseRecordPagination recordPagination;
  final bool isLoading;
  final ErrorState? error;

  const ExerciseRecordState({
    required this.exerciseRecords,
    this.selectedExerciseRecord,
    this.latestExerciseRecord,
    required this.recordPagination,
    required this.isLoading,
    this.error,
  });

  factory ExerciseRecordState.initial() {
    return ExerciseRecordState(
      exerciseRecords: [],
      recordPagination: ExerciseRecordPagination.initial(),
      isLoading: false,
    );
  }

  ExerciseRecordState copyWith({
    List<ExerciseRecordDto>? exerciseRecords,
    Nullable<ExerciseRecordDto>? selectedExerciseRecord,
    Nullable<ExerciseRecordDto>? latestExerciseRecord,
    ExerciseRecordPagination? recordPagination,
    bool? isLoading,
    Nullable<ErrorState>? error,
  }) {
    return ExerciseRecordState(
      exerciseRecords: exerciseRecords ?? this.exerciseRecords,
      selectedExerciseRecord: selectedExerciseRecord != null
          ? selectedExerciseRecord.value
          : this.selectedExerciseRecord,
      latestExerciseRecord: latestExerciseRecord != null
          ? latestExerciseRecord.value
          : this.latestExerciseRecord,
      recordPagination: recordPagination ?? this.recordPagination,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error.value : this.error,
    );
  }

  @override
  List<Object?> get props => [
        exerciseRecords,
        selectedExerciseRecord,
        latestExerciseRecord,
        recordPagination,
        isLoading,
        error,
      ];
}
