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
import 'package:go_router/go_router.dart';

import '../view_models/states/workout_plan_record_state.dart';
import '../view_models/workout_plan_record_cubit.dart';
import '../../../data/utils/enums.dart';
import '../../../routing/routes.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../widgets/active/active_workout_plan_content.dart';
import '../widgets/active/current_workout_plan_placeholder.dart';

class CurrentWorkoutPlanScreen extends StatefulWidget {
  final bool isVisible;

  const CurrentWorkoutPlanScreen({super.key, this.isVisible = true});

  @override
  State<CurrentWorkoutPlanScreen> createState() =>
      _CurrentWorkoutPlanScreenState();
}

class _CurrentWorkoutPlanScreenState extends State<CurrentWorkoutPlanScreen> {
  bool _refreshing = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) _scheduleRefresh();
  }

  @override
  void didUpdateWidget(CurrentWorkoutPlanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible &&
        !oldWidget.isVisible &&
        !_hasLoaded &&
        !_refreshing) {
      _scheduleRefresh();
    }
  }

  void _scheduleRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    final cubit = context.read<WorkoutPlanRecordCubit>();
    try {
      // The dashboard and plan actions share this Cubit. Let their load finish
      // before refreshing the current execution.
      if (cubit.state.isLoading) {
        await cubit.stream.firstWhere((state) => !state.isLoading);
      }
      if (!mounted) return;
      await cubit.getLatestActivePlanRecord();
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
          _hasLoaded = true;
        });
      }
    }
  }

  Future<void> _openAllPlans() async {
    await context.push(Routes.workoutPlanList.name);
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      BreakPoint.fromContext(context).screenSize,
    );
    return AppScaffold(
      title: 'Current Plan',
      showBackButton: false,
      body: Padding(
        padding: EdgeInsets.all(sizes.viewPadding),
        child: BlocBuilder<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
          builder: (context, state) {
            if (!_hasLoaded || _refreshing || state.isLoading) {
              return ActiveWorkoutPlanContent(
                state: state.currentPlanRecord,
                isLoading: true,
                sizes: sizes,
              );
            }
            if (state.error != null) {
              return CurrentWorkoutPlanPlaceholder(
                sizes: sizes,
                errorDescription: state.error!.description,
                onRetry: _refresh,
              );
            }
            final current = state.currentPlanRecord;
            if (current.workoutPlan == null ||
                current.currentPlanRecord?.status !=
                    ProgressStatus.inProgress) {
              return CurrentWorkoutPlanPlaceholder(
                sizes: sizes,
                onRetry: _refresh,
                onBrowsePlans: _openAllPlans,
              );
            }
            return ActiveWorkoutPlanContent(
              state: current,
              isLoading: false,
              sizes: sizes,
            );
          },
        ),
      ),
    );
  }
}
