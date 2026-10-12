import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../cubits/macro_tracking_cubit.dart';
import '../../cubits/states/macro_tracking_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/macro_goals/macro_goal_form_modal.dart';

class MacroGoalsView extends StatefulWidget {
  static const routeName = '/macro-goals';
  static const name = 'macro_goals';

  const MacroGoalsView({super.key});

  @override
  State<MacroGoalsView> createState() => _MacroGoalsViewState();
}

class _MacroGoalsViewState extends State<MacroGoalsView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<MacroTrackingCubit>();
    cubit.getActiveMacroGoal();
    cubit.getMacroGoals();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return AppScaffold(
      title: 'Macro Goals',
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocConsumer<MacroTrackingCubit, MacroTrackingState>(
          listener: (context, state) {
            if (!state.isLoading && state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!.description)),
              );
            }
          },
          builder: (context, state) {
            final activeGoal = state.activeGoal;
            final history =
                state.goalHistory.where((g) => g.id != activeGoal?.id).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Active Macro Goal Card
                if (activeGoal == null)
                  Card(
                    elevation: 1,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.all(sizes.padding * 1.5),
                      child: Column(
                        children: [
                          Icon(
                            Icons.track_changes,
                            size: sizes.titleFontSize * 2,
                            color: Colors.grey,
                          ),
                          SizedBox(height: sizes.spacing),
                          Text(
                            'No Active Macro Goal',
                            style: TextStyle(
                              fontSize: sizes.subtitleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: sizes.spacing / 2),
                          Text(
                            'Set your target daily calories, protein, carbs, and fats.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: sizes.spacing),
                          ElevatedButton.icon(
                            key: const ValueKey('macro-goal-set-button'),
                            icon: const Icon(Icons.add),
                            label: const Text('Set Goal'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => MacroGoalFormModal(
                                  theme: theme,
                                  sizes: sizes,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
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
                              Text(
                                'Active Macro Target',
                                style: TextStyle(
                                  fontSize: sizes.subtitleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              IconButton(
                                key: const ValueKey('macro-goal-edit-btn'),
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => MacroGoalFormModal(
                                      theme: theme,
                                      sizes: sizes,
                                      existingGoal: activeGoal,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: sizes.spacing / 2),
                          Text(
                            '${activeGoal.targetCalories} kcal / day',
                            style: TextStyle(
                              fontSize: sizes.titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: sizes.spacing),
                          Row(
                            children: [
                              _GoalChip(
                                label: 'Protein',
                                value: '${activeGoal.targetProtein}g',
                                color: Colors.blue,
                                sizes: sizes,
                              ),
                              SizedBox(width: sizes.spacing),
                              _GoalChip(
                                label: 'Carbs',
                                value: '${activeGoal.targetCarbs}g',
                                color: Colors.amber,
                                sizes: sizes,
                              ),
                              SizedBox(width: sizes.spacing),
                              _GoalChip(
                                label: 'Fat',
                                value: '${activeGoal.targetFat}g',
                                color: Colors.red,
                                sizes: sizes,
                              ),
                              if (activeGoal.targetWaterIntakeMl != null) ...[
                                SizedBox(width: sizes.spacing),
                                _GoalChip(
                                  label: 'Water',
                                  value: '${activeGoal.targetWaterIntakeMl}ml',
                                  color: Colors.cyan,
                                  sizes: sizes,
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: sizes.spacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                key:
                                    const ValueKey('macro-goal-deactivate-btn'),
                                icon: const Icon(Icons.stop_circle_outlined,
                                    color: Colors.orange),
                                label: const Text('Deactivate',
                                    style: TextStyle(color: Colors.orange)),
                                onPressed: () {
                                  context
                                      .read<MacroTrackingCubit>()
                                      .completeMacroGoal(activeGoal.id);
                                },
                              ),
                              SizedBox(width: sizes.spacing),
                              TextButton.icon(
                                key: const ValueKey('macro-goal-delete-btn'),
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                label: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => ConfirmationDialog(
                                      title: 'Delete Macro Goal',
                                      content:
                                          'Are you sure you want to delete this macro goal?',
                                      onConfirm: () {
                                        context
                                            .read<MacroTrackingCubit>()
                                            .deleteMacroGoal(activeGoal.id);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: sizes.spacing * 2),
                Text(
                  'Goal History',
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sizes.spacing),
                Expanded(
                  child: history.isEmpty
                      ? Center(
                          child: Text(
                            'No past macro goals.',
                            style: TextStyle(
                              fontSize: sizes.fontSize,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: history.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: sizes.spacing / 2),
                          itemBuilder: (context, index) {
                            final g = history[index];
                            final dateStr = DateFormat('MMM d, yyyy').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    g.createdAt * 1000));

                            return Card(
                              margin: EdgeInsets.zero,
                              child: ListTile(
                                title: Text(
                                  '${g.targetCalories} kcal • P: ${g.targetProtein}g C: ${g.targetCarbs}g F: ${g.targetFat}g',
                                  style: TextStyle(
                                    fontSize: sizes.fontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Water: ${g.targetWaterIntakeMl ?? 0}ml${dateStr.isNotEmpty ? ' • $dateStr' : ''}',
                                  style: TextStyle(
                                    fontSize: sizes.fontSize * 0.9,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.grey),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => ConfirmationDialog(
                                        title: 'Delete Past Goal',
                                        content:
                                            'Are you sure you want to delete this past goal?',
                                        onConfirm: () {
                                          context
                                              .read<MacroTrackingCubit>()
                                              .deleteMacroGoal(g.id);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('macro-goal-add-fab'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => MacroGoalFormModal(
              theme: theme,
              sizes: sizes,
            ),
          );
        },
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final DataDisplaySizesList sizes;

  const _GoalChip({
    required this.label,
    required this.value,
    required this.color,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: sizes.fontSize * 0.8,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: sizes.subtitleFontSize * 0.9,
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
