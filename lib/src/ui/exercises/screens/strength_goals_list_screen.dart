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

import '../../../data/utils/enums.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../home/view_models/profile_cubit.dart';
import '../../home/view_models/states/profile_state.dart';
import '../view_models/exercise_record_cubit.dart';
import '../view_models/states/exercise_record_state.dart';
import '../widgets/strength_goal/active_strength_goal_card.dart';
import '../widgets/strength_goal/create_strength_goal_modal.dart';
import '../widgets/strength_goal/strength_goal_history.dart';

class StrengthGoalsScreen extends StatefulWidget {
  static const name = 'strength-goals';

  const StrengthGoalsScreen({super.key});

  @override
  State<StrengthGoalsScreen> createState() => _StrengthGoalsScreenState();
}

class _StrengthGoalsScreenState extends State<StrengthGoalsScreen> {
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

    return ResponsiveScaffold(
      title: 'Strength Goals',
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          final units = profileState.system?.units ?? Units.metric;

          return Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: BlocConsumer<ExerciseRecordCubit, ExerciseRecordState>(
              listenWhen: (previous, current) =>
                  current.error != null && current.error != previous.error,
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!.description),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ActiveStrengthGoalCard(
                      sizes: sizes,
                      theme: theme,
                      units: units,
                    ),
                    SizedBox(height: sizes.spacing),
                    StrengthGoalHistory(
                      theme: theme,
                      breakPoint: breakpoints,
                      sizes: sizes,
                      units: units,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('strength-goal-add-fab'),
        elevation: sizes.elevation,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>
                CreateStrengthGoalModal(theme: theme, sizes: sizes),
          );
        },
        child: Icon(Icons.add, size: sizes.buttonIconSize),
      ),
    );
  }
}
