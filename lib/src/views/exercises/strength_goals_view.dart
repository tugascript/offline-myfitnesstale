import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/exercise_record_cubit.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/exercises/strength_goal/active_strength_goal_card.dart';
import '../../widgets/exercises/strength_goal/strength_goal_form_modal.dart';
import '../../widgets/exercises/strength_goal/strength_goal_history_list.dart';
import '../../widgets/layout/app_scaffold.dart';

class StrengthGoalsView extends StatefulWidget {
  static const routeName = '/strength-goals';
  static const name = 'strength-goals';

  const StrengthGoalsView({super.key});

  @override
  State<StrengthGoalsView> createState() => _StrengthGoalsViewState();
}

class _StrengthGoalsViewState extends State<StrengthGoalsView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExerciseRecordCubit>();
    cubit.getActiveStrengthGoal();
    cubit.getStrengthGoals();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return AppScaffold(
      title: 'Strength Goals',
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: Column(
          children: [
            ActiveStrengthGoalCard(
              sizes: sizes,
              theme: theme,
            ),
            SizedBox(height: sizes.spacing * 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Goal History',
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: sizes.spacing),
            Expanded(
              child: StrengthGoalHistoryList(
                sizes: sizes,
                theme: theme,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('strength-goal-add-fab'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => StrengthGoalFormModal(
              theme: theme,
              sizes: sizes,
            ),
          );
        },
        child: Icon(
          Icons.add,
          size: sizes.buttonIconSize,
        ),
      ),
    );
  }
}
