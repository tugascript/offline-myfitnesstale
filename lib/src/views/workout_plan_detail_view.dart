import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfitnesstale/src/widgets/workout_plan/details/workout_plan_header.dart';

import '../cubits/states/workout_plan_state.dart';
import '../cubits/workout_plan_cubit.dart';
import '../models/enums.dart';
import '../utilities/sizes/data_display_sizes.dart';
import '../utilities/sizes/screen_size.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/workout_plan/details/workout_plan_week_card.dart';
import 'error_view.dart';
import 'loading_view.dart';

class WorkoutPlanDetailView extends StatefulWidget {
  static const String routeName = "/workout-plans/:id";
  static const String name = 'workout-plan-detail';

  final int workoutPlanId;

  const WorkoutPlanDetailView({
    super.key,
    required this.workoutPlanId,
  });

  @override
  State<WorkoutPlanDetailView> createState() => _WorkoutPlanDetailViewState();
}

class _WorkoutPlanDetailViewState extends State<WorkoutPlanDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutPlanCubit>().getWorkoutPlan(widget.workoutPlanId);
  }

  @override
  Widget build(BuildContext context) {
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getWorkoutDetailSizes(
      breakpoints.screenSize,
    );

    return BlocConsumer<WorkoutPlanCubit, WorkoutPlanState>(
      builder: (context, state) {
        if (state.isLoading ||
            (state.selectedWorkoutPlan == null && state.error == null)) {
          return LoadingView();
        }

        if (!state.isLoading && state.error != null) {
          return ErrorView(
            description: state.error!.description,
            type: state.error!.type,
          );
        }

        final plan = state.selectedWorkoutPlan!;

        return ResponsiveScaffold(
          title: plan.name,
          isEntity: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Header
              WorkoutPlanHeader(
                sizes: sizes,
                plan: plan,
              ),
              const SizedBox(height: 24),
              // Weekly Breakdown
              Text(
                'Weekly Breakdown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              ...(plan.weeks?.map(
                    (week) => WorkoutPlanWeekCard(week: week),
                  ) ??
                  []),
            ],
          ),
        );
      },
      listener: (context, state) {
        if (state.isLoading) {
          return;
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!.description),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (state.selectedWorkoutPlan == null ||
            state.selectedWorkoutPlan!.id != widget.workoutPlanId) {
          context.read<WorkoutPlanCubit>().getWorkoutPlan(widget.workoutPlanId);
        }
      },
    );
  }
}
