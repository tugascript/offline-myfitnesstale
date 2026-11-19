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

import '../../../../data/repositories/exercises/dtos/strength_goal_dto.dart';
import '../../../../data/repositories/exercises/inputs/strength_goal_input.dart';
import '../../../../data/utils/enums.dart';
import '../../../../utils/nullable.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/widgets/layout/app_modal.dart';
import '../../../home/view_models/profile_cubit.dart';
import '../../view_models/exercise_record_cubit.dart';
import '../../view_models/states/exercise_record_state.dart';
import 'strength_goal_form.dart';

class EditStrengthGoalModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final StrengthGoalDto existingGoal;

  const EditStrengthGoalModal({
    super.key,
    required this.theme,
    required this.sizes,
    required this.existingGoal,
  });

  Future<void> _onSubmit(
    BuildContext context, {
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
    final success = await cubit.updateStrengthGoal(
      existingGoal.id,
      StrengthGoalInput(
        name: Nullable(name),
        targetWeight: targetWeightGrams,
        targetReps: targetReps,
        targetMaxStrength: targetMaxStrength,
        status: existingGoal.status,
        exerciseId: existingGoal.exerciseId,
        startDate: existingGoal.startDate,
        completedAt: Nullable(existingGoal.completedAt),
      ),
    );

    if (!context.mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          cubit.state.error?.description ?? 'Failed to save strength goal',
          style: TextStyle(fontSize: sizes.fontSize),
        ),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileUnits =
        context.watch<ProfileCubit>().state.system?.units ?? Units.metric;
    final weightVal = profileUnits == Units.imperial
        ? Converters.gramsToLbs(existingGoal.targetWeight)
        : Converters.gramsToKg(existingGoal.targetWeight);

    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
        builder: (context, state) => StrengthGoalForm(
          theme: theme,
          sizes: sizes,
          initialName: existingGoal.name,
          initialWeight: weightVal.toStringAsFixed(1),
          initialReps: existingGoal.targetReps.toString(),
          initialExerciseId: existingGoal.exerciseId,
          isLoading: state.isLoading,
          submitLabel: 'UPDATE STRENGTH GOAL',
          submitIcon: Icons.save,
          units: profileUnits,
          onSubmit:
              ({
                name,
                required targetWeight,
                required targetReps,
                required targetMaxStrength,
                required exerciseId,
              }) => _onSubmit(
                context,
                name: name,
                targetWeight: targetWeight,
                targetReps: targetReps,
                targetMaxStrength: targetMaxStrength,
                exerciseId: exerciseId,
              ),
        ),
      ),
    );
  }
}
