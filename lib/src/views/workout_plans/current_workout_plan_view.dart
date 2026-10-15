import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/states/workout_plan_record_state.dart';
import '../../cubits/workout_plan_record_cubit.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/workout_plan/active/active_workout_plan_content.dart';
import '../../widgets/workout_plan/active/current_workout_plan_placeholder.dart';
import 'workout_plan_list_view.dart';

class CurrentWorkoutPlanView extends StatefulWidget {
  final bool isVisible;

  const CurrentWorkoutPlanView({super.key, this.isVisible = true});

  @override
  State<CurrentWorkoutPlanView> createState() => _CurrentWorkoutPlanViewState();
}

class _CurrentWorkoutPlanViewState extends State<CurrentWorkoutPlanView> {
  bool _refreshing = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) _scheduleRefresh();
  }

  @override
  void didUpdateWidget(CurrentWorkoutPlanView oldWidget) {
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
    await context.push(WorkoutPlanListView.routeName);
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
