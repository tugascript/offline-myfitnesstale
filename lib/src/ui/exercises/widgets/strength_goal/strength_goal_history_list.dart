// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../view_models/exercise_record_cubit.dart';
import '../../../home/view_models/profile_cubit.dart';
import '../../view_models/states/exercise_record_state.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/utils/converters.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/confirmation_dialog.dart';

class StrengthGoalHistoryList extends StatelessWidget {
  final ThemeData theme;
  final bool shrinkWrap;
  final DataDisplaySizesList sizes;

  const StrengthGoalHistoryList({
    super.key,
    this.shrinkWrap = false,
    required this.theme,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final profileUnits =
        context.watch<ProfileCubit>().state.system?.units ?? Units.metric;

    return BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
      builder: (context, state) {
        final history = state.strengthGoals
            .where((g) => g.id != state.activeStrengthGoal?.id)
            .toList();

        if (history.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(sizes.padding),
              child: Text(
                'No past strength goals found.',
                style: TextStyle(fontSize: sizes.fontSize, color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          itemCount: history.length,
          separatorBuilder: (_, _) => SizedBox(height: sizes.spacing / 2),
          itemBuilder: (context, index) {
            final goal = history[index];
            final weightString = profileUnits == Units.imperial
                ? '${Converters.gramsToLbs(goal.targetWeight).toStringAsFixed(1)} lbs'
                : '${Converters.gramsToKg(goal.targetWeight).toStringAsFixed(1)} kg';

            final isCompleted = goal.status == ProgressStatus.completed;
            final dateText = goal.completedAt != null
                ? DateFormat('MMM d, yyyy').format(goal.completedAt!)
                : DateFormat('MMM d, yyyy').format(goal.startDate);

            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.grey,
                  size: sizes.buttonIconSize,
                ),
                title: Text(
                  goal.name,
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '$weightString × ${goal.targetReps} reps • 1RM: ${goal.targetMaxStrength}'
                  '${dateText.isNotEmpty ? '\n$dateText' : ''}',
                  style: TextStyle(
                    fontSize: sizes.fontSize * 0.9,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.grey,
                    size: sizes.buttonIconSize,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => ConfirmationDialog(
                        title: 'Delete Past Goal',
                        content: 'Are you sure you want to delete this historical goal record?',
                        onConfirm: () {
                          context
                              .read<ExerciseRecordCubit>()
                              .deleteStrengthGoal(goal.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
