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

import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../view_models/macro_tracking_cubit.dart';
import '../view_models/states/macro_tracking_state.dart';
import '../widgets/goals/macro_goal_form_modal.dart';
import '../widgets/goals/macro_goals_content_widget.dart';

class MacroGoalsScreen extends StatefulWidget {
  static const name = 'macro_goals';

  const MacroGoalsScreen({super.key});

  @override
  State<MacroGoalsScreen> createState() => _MacroGoalsScreenState();
}

class _MacroGoalsScreenState extends State<MacroGoalsScreen> {
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
                SnackBar(
                  content: Text(
                    state.error!.description,
                    style: TextStyle(fontSize: sizes.fontSize),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return MacroGoalsContentWidget(
              state: state,
              theme: theme,
              sizes: sizes,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('macro-goal-add-fab'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => MacroGoalFormModal(theme: theme, sizes: sizes),
          );
        },
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
