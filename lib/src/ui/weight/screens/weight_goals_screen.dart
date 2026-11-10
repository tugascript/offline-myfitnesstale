import 'package:flutter/material.dart';

import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../widgets/goal/active/active_weight_goal.dart';
import '../widgets/goal/editor/create_weight_goal_modal.dart';
import '../widgets/goal/history/weight_goal_history.dart';

class WeightGoalScreen extends StatelessWidget {
  static const name = "weight-goal";

  const WeightGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);
    return AppScaffold(
      title: "Weight Goals",
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: Column(
          children: [
            ActiveWeightGoal(sizes: sizes, theme: theme),
            SizedBox(height: sizes.spacing * 2),
            Expanded(
              child: WeightGoalHistory(sizes: sizes, theme: theme),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('weight-goal-add'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>
                CreateWeightGoalModal(theme: theme, sizes: sizes),
          );
        },
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
