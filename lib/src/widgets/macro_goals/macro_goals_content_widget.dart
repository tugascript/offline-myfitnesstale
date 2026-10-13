import '../../widgets/macro_goals/macro_goal_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/macro_tracking_cubit.dart';
import '../../cubits/states/macro_tracking_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/macro_goals/macro_goal_form_modal.dart';

class MacroGoalsContentWidget extends StatelessWidget {
  final MacroTrackingState state;
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  const MacroGoalsContentWidget(
      {super.key,
      required this.state,
      required this.theme,
      required this.sizes});
  @override
  Widget build(BuildContext context) {
    final activeGoal = state.activeGoal;
    final history =
        state.goalHistory.where((g) => g.id != activeGoal?.id).toList();

    return SingleChildScrollView(
        child: Column(
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
                    icon: Icon(Icons.add, size: sizes.buttonIconSize),
                    label: Text('Set Goal',
                        style: TextStyle(fontSize: sizes.fontSize)),
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
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: sizes.spacing,
                    runSpacing: sizes.spacing,
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
                        icon: Icon(Icons.edit_outlined,
                            size: sizes.buttonIconSize),
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
                  Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: sizes.spacing / 2,
                    runSpacing: sizes.spacing / 2,
                    children: [
                      MacroGoalChip(
                        label: 'Protein',
                        value: '${activeGoal.targetProtein}g',
                        color: Colors.blue,
                        sizes: sizes,
                      ),
                      SizedBox(width: sizes.spacing),
                      MacroGoalChip(
                        label: 'Carbs',
                        value: '${activeGoal.targetCarbs}g',
                        color: Colors.amber,
                        sizes: sizes,
                      ),
                      SizedBox(width: sizes.spacing),
                      MacroGoalChip(
                        label: 'Fat',
                        value: '${activeGoal.targetFat}g',
                        color: Colors.red,
                        sizes: sizes,
                      ),
                      if (activeGoal.targetWaterIntakeMl != null) ...[
                        SizedBox(width: sizes.spacing),
                        MacroGoalChip(
                          label: 'Water',
                          value: '${activeGoal.targetWaterIntakeMl}ml',
                          color: Colors.cyan,
                          sizes: sizes,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: sizes.spacing),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: sizes.spacing,
                    runSpacing: sizes.spacing,
                    children: [
                      TextButton.icon(
                        key: const ValueKey('macro-goal-deactivate-btn'),
                        icon: Icon(Icons.stop_circle_outlined,
                            color: Colors.orange, size: sizes.buttonIconSize),
                        label: Text('Deactivate',
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: sizes.fontSize)),
                        onPressed: () {
                          context
                              .read<MacroTrackingCubit>()
                              .completeMacroGoal(activeGoal.id);
                        },
                      ),
                      SizedBox(width: sizes.spacing),
                      TextButton.icon(
                        key: const ValueKey('macro-goal-delete-btn'),
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red, size: sizes.buttonIconSize),
                        label: Text('Delete',
                            style: TextStyle(
                                color: Colors.red, fontSize: sizes.fontSize)),
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
        history.isEmpty
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
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: sizes.spacing / 2),
                itemBuilder: (context, index) {
                  final g = history[index];

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
                        'Water: ${g.targetWaterIntakeMl ?? 0}ml • ${g.name}',
                        style: TextStyle(
                          fontSize: sizes.fontSize * 0.9,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.grey, size: sizes.buttonIconSize),
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
      ],
    ));
  }
}
