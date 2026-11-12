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
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/utils/enums.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../home/view_models/profile_cubit.dart';
import '../../home/view_models/states/profile_state.dart';
import '../view_models/states/workout_plan_record_state.dart';
import '../view_models/states/workout_plan_state.dart';
import '../view_models/workout_plan_cubit.dart';
import '../view_models/workout_plan_record_cubit.dart';
import '../widgets/history/latest_workout_plan_record.dart';
import '../widgets/history/workout_plan_record_history.dart';

class WorkoutPlanHistoryScreen extends StatefulWidget {
  final int? workoutPlanId;
  final int? version;

  const WorkoutPlanHistoryScreen({super.key, this.workoutPlanId, this.version});

  static String location([int? workoutPlanId, int? version]) {
    if (workoutPlanId == null) {
      return Routes.workoutPlanHistory.name;
    }
    if (version == null) {
      return '${Routes.workoutPlanHistory.name}?id=$workoutPlanId';
    }
    return '${Routes.workoutPlanHistory.name}?id=$workoutPlanId&version=$version';
  }

  @override
  State<WorkoutPlanHistoryScreen> createState() =>
      _WorkoutPlanHistoryScreenState();
}

class _WorkoutPlanHistoryScreenState extends State<WorkoutPlanHistoryScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.workoutPlanId != null) {
      final workoutPlanCubit = context.read<WorkoutPlanCubit>();
      if (workoutPlanCubit.state.selectedWorkoutPlan?.id !=
          widget.workoutPlanId) {
        workoutPlanCubit.getWorkoutPlan(widget.workoutPlanId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);
    final isSinglePlan = widget.workoutPlanId != null;

    return BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
      builder: (context, workoutPlanState) {
        final selectedWorkoutPlan =
            workoutPlanState.selectedWorkoutPlan?.id == widget.workoutPlanId &&
                !workoutPlanState.isLoading
            ? workoutPlanState.selectedWorkoutPlan
            : null;
        final workoutPlanVersion = isSinglePlan
            ? (widget.version ?? selectedWorkoutPlan?.currentVersion ?? 1)
            : null;

        return ResponsiveScaffold(
          title: isSinglePlan
              ? (selectedWorkoutPlan?.name ?? 'Plan History')
              : 'Plan History',
          isEntity: isSinglePlan,
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final units = profileState.system?.units ?? Units.metric;
              return Padding(
                padding: EdgeInsets.all(sizes.viewPadding),
                child:
                    BlocConsumer<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
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
                        LatestWorkoutPlanRecord(
                          sizes: sizes,
                          theme: theme,
                          units: units,
                          workoutPlanId: widget.workoutPlanId,
                          workoutPlanVersion: workoutPlanVersion,
                        ),
                        SizedBox(height: sizes.spacing),
                        WorkoutPlanRecordHistory(
                          theme: theme,
                          breakPoint: breakpoints,
                          sizes: sizes,
                          units: units,
                          workoutPlanId: widget.workoutPlanId,
                          workoutPlanVersion: workoutPlanVersion,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          floatingActionButton: isSinglePlan
              ? FloatingActionButton(
                  key: const ValueKey('workout-plan-record-start'),
                  elevation: sizes.elevation,
                  onPressed: () {
                    context.push(
                      '/workout-plans/${widget.workoutPlanId}/active',
                    );
                  },
                  child: const Icon(Icons.play_arrow),
                )
              : null,
        );
      },
    );
  }
}
