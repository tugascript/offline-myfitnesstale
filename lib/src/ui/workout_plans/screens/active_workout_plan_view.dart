import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view_models/states/workout_plan_record_state.dart';
import '../view_models/workout_plan_record_cubit.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../widgets/active/active_workout_plan_content.dart';
import '../../core/screens/entity_error_view.dart';

class ActiveWorkoutPlanView extends StatefulWidget {
  final int workoutPlanId;

  const ActiveWorkoutPlanView({super.key, required this.workoutPlanId});

  @override
  State<ActiveWorkoutPlanView> createState() => _ActiveWorkoutPlanViewState();
}

class _ActiveWorkoutPlanViewState extends State<ActiveWorkoutPlanView> {
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
          return EntityErrorView(
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
