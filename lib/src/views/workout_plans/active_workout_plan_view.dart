import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/states/workout_plan_record_state.dart';
import '../../cubits/workout_plan_record_cubit.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/app_scaffold.dart';
import '../../widgets/workout_plan/active/active_workout_plan_content.dart';
import '../entity_error_view.dart';

class ActiveWorkoutPlanView extends StatefulWidget {
  static const routeName = '/workout-plans/:id/active';

  final int workoutPlanId;

  const ActiveWorkoutPlanView({
    super.key,
    required this.workoutPlanId,
  });

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
    final sizes = DataDisplaySizes.getDataDisplaySizes(
      breakpoints.screenSize,
    );

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
