import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/enums.dart';
import '../services/weight_goal_service.dart';
import 'states/weight_goal_state.dart';

class WeightGoalCubit extends Cubit<WeightGoalState> {
  final WeightGoalService _weightGoalService = WeightGoalService();

  WeightGoalCubit() : super(WeightGoalState.initial());

  Future<void> getWeightGoals({
    required int limit,
    required int offset,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final weightGoals = await _weightGoalService.getWeightGoals(
        limit: limit,
        offset: offset,
      );

      emit(state.copyWith(
        weightGoals: offset >= state.pagination.offset + limit
            ? [...state.weightGoals, ...weightGoals]
            : weightGoals,
        pagination: state.pagination.copyWith(
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

  Future<void> getActiveWeightGoal() async {
    emit(state.copyWith(isLoading: true));

    try {
      final activeGoal = await _weightGoalService.getActiveWeightGoal();
      emit(state.copyWith(
        activeWeightGoal: activeGoal,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> createWeightGoal({
    required int targetWeight,
    required DateTime startDate,
    required DateTime endDate,
    ProgressStatus status = ProgressStatus.inProgress,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final weightGoal = await _weightGoalService.createWeightGoal(
        targetWeight: targetWeight,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );

      emit(state.copyWith(
        weightGoals: [weightGoal, ...state.weightGoals],
        selectedWeightGoal: weightGoal,
        activeWeightGoal: status == ProgressStatus.inProgress
            ? weightGoal
            : state.activeWeightGoal,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> updateWeightGoal({
    required int id,
    int? targetWeight,
    DateTime? startDate,
    DateTime? endDate,
    ProgressStatus? status,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final weightGoal = await _weightGoalService.updateWeightGoal(
        id: id,
        targetWeight: targetWeight,
        startDate: startDate,
        endDate: endDate,
        status: status,
      );

      emit(state.copyWith(
        weightGoals: state.weightGoals
            .map((g) => g.id == weightGoal.id ? weightGoal : g)
            .toList(),
        selectedWeightGoal: weightGoal,
        activeWeightGoal: status == ProgressStatus.inProgress
            ? weightGoal
            : (state.activeWeightGoal?.id == id
                ? null
                : state.activeWeightGoal),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> deleteWeightGoal(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final success = await _weightGoalService.deleteWeightGoal(id);

      if (success) {
        emit(state.copyWith(
          weightGoals: state.weightGoals.where((g) => g.id != id).toList(),
          selectedWeightGoal: state.selectedWeightGoal?.id == id
              ? null
              : state.selectedWeightGoal,
          activeWeightGoal:
              state.activeWeightGoal?.id == id ? null : state.activeWeightGoal,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: 'Failed to delete weight goal',
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

  Future<void> completeWeightGoal(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final completedGoal =
          await _weightGoalService.completeWeightGoal(id, DateTime.now());

      final updatedGoals = state.weightGoals.map((goal) {
        if (goal.id == id) {
          return completedGoal;
        }
        return goal;
      }).toList();

      emit(state.copyWith(
        weightGoals: updatedGoals,
        selectedWeightGoal: state.selectedWeightGoal?.id == id
            ? completedGoal
            : state.selectedWeightGoal,
        activeWeightGoal:
            state.activeWeightGoal?.id == id ? null : state.activeWeightGoal,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> abandonWeightGoal(int id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final abandonedGoal = await _weightGoalService.updateWeightGoal(
        id: id,
        status: ProgressStatus.abandoned,
      );

      final updatedGoals = state.weightGoals.map((goal) {
        if (goal.id == id) {
          return abandonedGoal;
        }
        return goal;
      }).toList();

      emit(state.copyWith(
        weightGoals: updatedGoals,
        selectedWeightGoal: state.selectedWeightGoal?.id == id
            ? abandonedGoal
            : state.selectedWeightGoal,
        activeWeightGoal:
            state.activeWeightGoal?.id == id ? null : state.activeWeightGoal,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> selectWeightGoal(int id) async {
    final goal = state.weightGoals.firstWhere((g) => g.id == id);
    emit(state.copyWith(selectedWeightGoal: goal));
  }

  void clearSelectedWeightGoal() {
    emit(state.copyWith(selectedWeightGoal: null));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
