// Copyright (C) 2026 afonsobarracha
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view_models/states/workout_plan_record_state.dart';
import '../view_models/workout_plan_record_cubit.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../widgets/active/active_workout_plan_content.dart';
import '../../core/screens/entity_error_screen.dart';

class ActiveWorkoutPlanScreen extends StatefulWidget {
  final int workoutPlanId;

  const ActiveWorkoutPlanScreen({super.key, required this.workoutPlanId});

  @override
  State<ActiveWorkoutPlanScreen> createState() =>
      _ActiveWorkoutPlanScreenState();
}

class _ActiveWorkoutPlanScreenState extends State<ActiveWorkoutPlanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<WorkoutPlanRecordCubit>();
        if (!cubit.state.isLoading &&
            cubit.state.currentPlanRecord.workoutPlan?.id !=
                widget.workoutPlanId) {
          cubit.getOrCreateActivePlanRecord(widget.workoutPlanId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
      builder: (context, state) {
        if (state.currentPlanRecord.workoutPlan == null && !state.isLoading) {
          return EntityErrorScreen(
            sizes: sizes,
            entityName: "Workout Plan",
            errorDescription: state.error?.description,
          );
        }

        return AppScaffold(
          title: "Active Workout Plan",
          isEntity: false,
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: ActiveWorkoutPlanContent(
              state: state.currentPlanRecord,
              isLoading: state.isLoading,
              sizes: sizes,
            ),
          ),
        );
      },
      listener: (context, state) {
        return;
      },
    );
  }
}
