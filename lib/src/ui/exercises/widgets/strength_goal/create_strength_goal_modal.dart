// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../data/repositories/exercises/inputs/strength_goal_input.dart';
import '../../../../data/utils/enums.dart';
import '../../../../utils/nullable.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/widgets/layout/app_modal.dart';
import '../../../home/view_models/profile_cubit.dart';
import '../../view_models/exercise_cubit.dart';
import '../../view_models/exercise_record_cubit.dart';
import '../../view_models/states/exercise_record_state.dart';
import 'strength_goal_form.dart';

class CreateStrengthGoalModal extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final int? exerciseId;

  const CreateStrengthGoalModal({
    super.key,
    required this.theme,
    required this.sizes,
    this.exerciseId,
  });

  @override
  State<CreateStrengthGoalModal> createState() =>
      _CreateStrengthGoalModalState();
}

class _CreateStrengthGoalModalState extends State<CreateStrengthGoalModal> {
  @override
  void initState() {
    super.initState();
    if (widget.exerciseId == null) {
      final exerciseState = context.read<ExerciseCubit>().state;
      if (exerciseState.exercises.isEmpty) {
        context.read<ExerciseCubit>().getExercises(limit: 100);
      }
    }
  }

  Future<void> _onSubmit({
    String? name,
    required double targetWeight,
    required int targetReps,
    required int targetMaxStrength,
    required int exerciseId,
  }) async {
    final profileUnits =
        context.read<ProfileCubit>().state.system?.units ?? Units.metric;
    final targetWeightGrams = profileUnits == Units.imperial
        ? Converters.lbsToGrams(targetWeight)
        : Converters.kgToGrams(targetWeight);

    final cubit = context.read<ExerciseRecordCubit>();
    final success = await cubit.createStrengthGoal(
      StrengthGoalInput(
        exerciseId: exerciseId,
        name: Nullable(name),
        targetWeight: targetWeightGrams,
        targetReps: targetReps,
        targetMaxStrength: targetMaxStrength,
        startDate: DateTime.now(),
        status: ProgressStatus.inProgress,
      ),
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          cubit.state.error?.description ?? 'Failed to save strength goal',
          style: TextStyle(fontSize: widget.sizes.fontSize),
        ),
        backgroundColor: widget.theme.colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileUnits =
        context.watch<ProfileCubit>().state.system?.units ?? Units.metric;
    final showExerciseSelection = widget.exerciseId == null;
    final exercises = showExerciseSelection
        ? context.watch<ExerciseCubit>().state.exercises
        : const <ExerciseDto>[];

    return AppModal(
      theme: widget.theme,
      sizes: widget.sizes,
      child: BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
        builder: (context, state) => StrengthGoalForm(
          theme: widget.theme,
          sizes: widget.sizes,
          initialExerciseId: widget.exerciseId,
          exercises: exercises,
          showExerciseSelection: showExerciseSelection,
          isLoading: state.isLoading,
          submitLabel: 'CREATE STRENGTH GOAL',
          units: profileUnits,
          onSubmit: _onSubmit,
        ),
      ),
    );
  }
}
