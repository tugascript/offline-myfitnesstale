import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/muscle_group_model.dart';
import '../services/muscle_group_service.dart';
import 'states/muscle_group_state.dart';

class MuscleGroupCubit extends Cubit<MuscleGroupState> {
  final MuscleGroupService _muscleGroupService = MuscleGroupService();

  MuscleGroupCubit() : super(MuscleGroupState.initial());

  Future<void> getMuscleGroups({
    String? name,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final List<MuscleGroup> muscleGroups =
          await _muscleGroupService.getMuscleGroups(
        name: name,
      );

      emit(state.copyWith(
        muscleGroups: muscleGroups,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> getMuscleGroup(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final MuscleGroup? muscleGroup =
          await _muscleGroupService.getMuscleGroup(id);

      emit(state.copyWith(
        selectedMuscleGroup: muscleGroup,
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
