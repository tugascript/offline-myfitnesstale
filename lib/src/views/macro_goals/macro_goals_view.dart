import '../../widgets/macro_goals/macro_goals_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/macro_tracking_cubit.dart';
import '../../cubits/states/macro_tracking_state.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
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
            return MacroGoalsContentWidget(
                state: state, theme: theme, sizes: sizes);
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
