import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/muscle_model.dart';
import '../services/muscle_service.dart';
import 'states/muscle_state.dart';

class MuscleCubit extends Cubit<MuscleState> {
  final MuscleService _muscleService = MuscleService();

  MuscleCubit() : super(MuscleState.initial());

  Future<void> getMuscles({
    String? name,
    int? muscleGroupId,
    int? limit,
    int? offset,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final List<Muscle> muscles = await _muscleService.getMuscles(
        name: name,
        muscleGroupId: muscleGroupId,
        limit: limit,
        offset: offset,
      );

      emit(state.copyWith(
        muscles: muscles,
        pagination: state.pagination.copyWith(
          name: name,
          muscleGroupId: muscleGroupId,
          limit: limit,
          offset: offset,
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

  Future<void> getMuscle(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final Muscle? muscle = await _muscleService.getMuscle(id);

      emit(state.copyWith(
        selectedMuscle: muscle,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }
}
