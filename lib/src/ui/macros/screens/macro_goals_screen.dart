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

import '../../../data/repositories/macros/dtos/macro_tracking_dto.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/view_models/states/common_state.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../view_models/macro_tracking_cubit.dart';
import '../view_models/states/macro_tracking_state.dart';
import '../widgets/goals/active_macro_goal.dart';
import '../widgets/goals/macro_goal_form_modal.dart';
import '../widgets/goals/macro_goal_history.dart';

class MacroGoalsScreen extends StatefulWidget {
  static const name = 'macro_goals';

  const MacroGoalsScreen({super.key});

  @override
  State<MacroGoalsScreen> createState() => _MacroGoalsScreenState();
}

class _MacroGoalsScreenState extends State<MacroGoalsScreen> {
  bool _isGoalModalOpen = false;
  ErrorState? _lastShownError;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<MacroTrackingCubit>();
    cubit.getActiveMacroGoal();
    cubit.getMacroGoals();
  }

  Future<void> _openGoalModal(
    ThemeData theme,
    DataDisplaySizesList sizes, {
    MacroGoalDto? existingGoal,
  }) async {
    if (_isGoalModalOpen || !mounted) return;
    _isGoalModalOpen = true;
    try {
      await showDialog<void>(
        context: context,
        builder: (_) => MacroGoalFormModal(
          theme: theme,
          sizes: sizes,
          existingGoal: existingGoal,
        ),
      );
    } finally {
      _isGoalModalOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return ResponsiveScaffold(
      title: 'Macro Goals',
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocConsumer<MacroTrackingCubit, MacroTrackingState>(
          listener: (context, state) {
            if (state.error == null || state.isLoading) {
              _lastShownError = null;
            } else if (state.error != _lastShownError) {
              _lastShownError = state.error;
              if (!_isGoalModalOpen) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.error!.description,
                      style: TextStyle(fontSize: sizes.fontSize),
                    ),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                ActiveMacroGoal(
                  theme: theme,
                  sizes: sizes,
                  activeGoal: state.activeGoal,
                  isLoading: state.isLoadingActiveGoal,
                  hasLoaded: state.hasLoadedActiveGoal,
                  hasError: state.activeGoalError != null,
                  onCreateGoal: () => _openGoalModal(theme, sizes),
                  onEditGoal: (goal) =>
                      _openGoalModal(theme, sizes, existingGoal: goal),
                  onRetry: () =>
                      context.read<MacroTrackingCubit>().getActiveMacroGoal(),
                ),
                SizedBox(height: sizes.spacing * 2),
                MacroGoalHistory(
                  sizes: sizes,
                  goals: state.goalHistory,
                  activeGoalId: state.activeGoal?.id,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('macro-goal-add-fab'),
        onPressed: () => _openGoalModal(theme, sizes),
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
