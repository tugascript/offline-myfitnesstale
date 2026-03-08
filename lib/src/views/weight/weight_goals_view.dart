import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/weight/goal/active/active_weight_goal.dart';
import '../../widgets/weight/goal/editor/create_weight_goal_modal.dart';
import '../../widgets/weight/goal/history/weight_goal_history.dart';

class WeightGoalView extends StatelessWidget {
  static const routeName = "/weight-goal";
  static const name = "weight-goal";

  const WeightGoalView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);
    return AppScaffold(
      title: "Weight Goals",
      body: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          children: [
            ActiveWeightGoal(
              sizes: sizes,
              theme: theme,
            ),
            SizedBox(height: sizes.spacing * 2),
            Expanded(
              child: WeightGoalHistory(
                sizes: sizes,
                theme: theme,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateWeightGoalModal(
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
