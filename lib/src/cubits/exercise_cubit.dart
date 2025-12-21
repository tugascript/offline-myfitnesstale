import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/enums.dart';
import '../models/equipment_model.dart';
import '../models/exercise_model.dart';
import '../models/muscle_model.dart';
import '../services/exercise_service.dart';
import 'states/exercise_state.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  final ExerciseService _exerciseService = ExerciseService();

  ExerciseCubit() : super(ExerciseState.initial());

  Future<void> getExercises({
    String? name,
    int? muscleGroupId,
    bool? isFavorite,
    int? difficulty,
    int? limit,
    int? offset,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final List<Exercise> exercises = await _exerciseService.getExercises(
        name: name,
        muscleGroupId: muscleGroupId,
        isFavorite: isFavorite,
        difficulty: difficulty,
        limit: limit,
        offset: offset,
      );

      emit(state.copyWith(
        exercises: exercises,
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

  Future<void> getExercise(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final Exercise? exercise = await _exerciseService.getExercise(id);
      final List<Muscle> muscles =
          await _exerciseService.getExerciseMuscles(id);
      final List<Equipment> equipments =
          await _exerciseService.getExerciseEquipments(id);

      emit(state.copyWith(
        selectedExercise: exercise,
        selectedExerciseMuscles: muscles,
        selectedExerciseEquipments: equipments,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> createExercise({
    required String name,
    required int muscleGroupId,
    String? description,
    String? pictureUri,
    (VideoPlatform, String)? videoData,
    List<(int, ExerciseMuscleCategory)>? muscleIds,
    List<int>? equipmentIds,
    int? difficulty,
    bool isFavorite = false,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final Exercise exercise = await _exerciseService.createExercise(
        name: name,
        muscleGroupId: muscleGroupId,
        description: description,
        pictureUri: pictureUri,
        videoData: videoData,
        muscleIds: muscleIds,
        equipmentIds: equipmentIds,
        difficulty: difficulty,
        isFavorite: isFavorite,
      );
      final List<Muscle> muscles =
          await _exerciseService.getExerciseMuscles(exercise.id!);
      final List<Equipment> equipments =
          await _exerciseService.getExerciseEquipments(exercise.id!);
      emit(state.copyWith(
        selectedExercise: exercise,
        selectedExerciseMuscles: muscles,
        selectedExerciseEquipments: equipments,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> updateExercise({
    required int id,
    String? name,
    String? description,
    int? muscleGroupId,
    String? pictureUri,
    String? videoUri,
    bool? isFavorite,
    int? difficulty,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final Exercise? updatedExercise = await _exerciseService.updateExercise(
        id,
        name: name,
        description: description,
        muscleGroupId: muscleGroupId,
        pictureUri: pictureUri,
        videoUri: videoUri,
        isFavorite: isFavorite,
        difficulty: difficulty,
      );

      if (updatedExercise != null) {
        final List<Muscle> muscles =
            await _exerciseService.getExerciseMuscles(id);
        final List<Equipment> equipments =
            await _exerciseService.getExerciseEquipments(id);
        emit(state.copyWith(
          selectedExercise: updatedExercise,
          selectedExerciseMuscles: muscles,
          selectedExerciseEquipments: equipments,
          isLoading: false,
        ));
        // Refresh exercises list if the updated exercise is in it
        if (state.exercises.any((e) => e.id == id)) {
          await getExercises(
            name: state.pagination.name,
            muscleGroupId: state.pagination.muscleGroupId,
            limit: state.pagination.limit,
            offset: state.pagination.offset,
          );
        }
      } else {
        emit(state.copyWith(
          error: 'Exercise not found',
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

  Future<void> deleteExercise(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final bool deleted = await _exerciseService.deleteExercise(id);
      if (deleted) {
        // Remove from current exercises list
        final List<Exercise> updatedExercises =
            state.exercises.where((e) => e.id != id).toList();
        emit(state.copyWith(
          exercises: updatedExercises,
          selectedExercise: state.selectedExercise?.id == id
              ? null
              : state.selectedExercise,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: 'Failed to delete exercise',
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

  Future<void> toggleFavorite(int id) async {
    final Exercise? exercise = await _exerciseService.getExercise(id);
    if (exercise != null) {
      await updateExercise(
        id: id,
        isFavorite: !exercise.isFavorite,
      );
    }
  }

  Future<void> getFavoriteExercises({
    int? limit,
    int? offset,
  }) async {
    await getExercises(
      isFavorite: true,
      limit: limit,
      offset: offset,
    );
  }
}
