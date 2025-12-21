import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/workout_record_service.dart';
import 'states/workout_record_state.dart';

class WorkoutRecordCubit extends Cubit<WorkoutRecordState> {
  final WorkoutRecordService _workoutRecordService = WorkoutRecordService();

  WorkoutRecordCubit() : super(WorkoutRecordState.initial());

  Future<void> getWorkoutRecords({
    int? workoutId,
    int? limit,
    int? offset,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final workoutRecords = await _workoutRecordService.getWorkoutRecords(
        workoutId: workoutId,
        limit: limit,
        offset: offset,
      );

      emit(state.copyWith(
        workoutRecords: offset != null && offset > 0
            ? [...state.workoutRecords, ...workoutRecords]
            : workoutRecords,
        pagination: state.pagination.copyWith(
          limit: limit ?? state.pagination.limit,
          offset: offset ?? state.pagination.offset,
        ),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> getWorkoutRecord(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final workoutRecord = await _workoutRecordService.getWorkoutRecord(id);
      emit(state.copyWith(
        selectedWorkoutRecord: workoutRecord,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> deleteWorkoutRecord(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final success = await _workoutRecordService.deleteWorkoutRecord(id);

      if (success) {
        emit(state.copyWith(
          workoutRecords:
              state.workoutRecords.where((w) => w.id != id).toList(),
          selectedWorkoutRecord: state.selectedWorkoutRecord?.id == id
              ? null
              : state.selectedWorkoutRecord,
          workoutRecordTotal: state.workoutRecordTotal - 1,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: 'Failed to delete workout record',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}
