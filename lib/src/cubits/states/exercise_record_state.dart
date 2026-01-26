import 'package:equatable/equatable.dart';

import '../../services/dtos/exercise_record_dto.dart';
import 'common_state.dart';

final class ExerciseRecordState extends Equatable {
  final List<ExerciseRecordDto> exerciseRecords;
  final ExerciseRecordDto? selectedExerciseRecord;
  final ExerciseRecordDto? latestExerciseRecord;
  final PaginationState recordPagination;
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
      recordPagination: PaginationState.initial(),
      isLoading: false,
    );
  }

  ExerciseRecordState copyWith({
    List<ExerciseRecordDto>? exerciseRecords,
    ExerciseRecordDto? selectedExerciseRecord,
    ExerciseRecordDto? latestExerciseRecord,
    PaginationState? recordPagination,
    bool? isLoading,
    ErrorState? error,
  }) {
    return ExerciseRecordState(
      exerciseRecords: exerciseRecords ?? this.exerciseRecords,
      selectedExerciseRecord:
          selectedExerciseRecord ?? this.selectedExerciseRecord,
      latestExerciseRecord: latestExerciseRecord ?? this.latestExerciseRecord,
      recordPagination: recordPagination ?? this.recordPagination,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
