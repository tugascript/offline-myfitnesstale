import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../cubits/exercise_record_cubit.dart';
import '../../../cubits/profile_cubit.dart';
import '../../../cubits/states/exercise_record_state.dart';
import '../../../models/enums.dart';
import '../../../utilities/converters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/confirmation_dialog.dart';
import 'strength_goal_form_modal.dart';

class ActiveStrengthGoalCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const ActiveStrengthGoalCard({
    super.key,
    required this.theme,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final profileUnits =
        context.watch<ProfileCubit>().state.system?.units ?? Units.metric;

    return BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
      builder: (context, state) {
        final goal = state.activeStrengthGoal;
        if (goal == null) {
          return Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(sizes.padding * 1.5),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: sizes.titleFontSize * 2,
                    color: Colors.grey,
                  ),
                  SizedBox(height: sizes.spacing),
                  Text(
                    'No Active Strength Goal',
                    style: TextStyle(
                      fontSize: sizes.subtitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: sizes.spacing / 2),
                  Text(
                    'Set a target weight and reps for an exercise to stay motivated.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: sizes.spacing),
                  ElevatedButton.icon(
                    key: const ValueKey('strength-goal-set-active-button'),
                    icon: const Icon(Icons.add),
                    label: const Text('Set Goal'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => StrengthGoalFormModal(
                          theme: theme,
                          sizes: sizes,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }

        final weightString = profileUnits == Units.imperial
            ? '${Converters.gramsToLbs(goal.targetWeight).toStringAsFixed(1)} lbs'
            : '${Converters.gramsToKg(goal.targetWeight).toStringAsFixed(1)} kg';

        return Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(sizes.padding * 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Active Strength Goal',
                        style: TextStyle(
                          fontSize: sizes.subtitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('active-strength-goal-edit-btn'),
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => StrengthGoalFormModal(
                            theme: theme,
                            sizes: sizes,
                            existingGoal: goal,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: sizes.spacing / 2),
                Text(
                  goal.name,
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sizes.spacing),
                Row(
                  children: [
                    _MetricChip(
                      label: 'Target Weight',
                      value: weightString,
                      sizes: sizes,
                    ),
                    SizedBox(width: sizes.spacing),
                    _MetricChip(
                      label: 'Reps',
                      value: '${goal.targetReps}',
                      sizes: sizes,
                    ),
                    SizedBox(width: sizes.spacing),
                    _MetricChip(
                      label: 'Target 1RM',
                      value: '${goal.targetMaxStrength}',
                      sizes: sizes,
                    ),
                  ],
                ),
                SizedBox(height: sizes.spacing),
                Text(
                  'Started: ${DateFormat('MMM d, yyyy').format(goal.startDate)}',
                  style: TextStyle(
                    fontSize: sizes.fontSize * 0.9,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: sizes.spacing * 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      key: const ValueKey('active-strength-goal-delete-btn'),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => ConfirmationDialog(
                            title: 'Delete Strength Goal',
                            content:
                                'Are you sure you want to delete this strength goal?',
                            onConfirm: () {
                              context
                                  .read<ExerciseRecordCubit>()
                                  .deleteStrengthGoal(goal.id);
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(width: sizes.spacing),
                    ElevatedButton.icon(
                      key: const ValueKey('active-strength-goal-complete-btn'),
                      icon: const Icon(Icons.check),
                      label: const Text('Complete Goal'),
                      onPressed: () {
                        context
                            .read<ExerciseRecordCubit>()
                            .completeStrengthGoal(goal.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final DataDisplaySizesList sizes;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: sizes.padding / 2,
          horizontal: sizes.padding / 2,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: sizes.fontSize * 0.8,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
