import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/states/workout_plan_state.dart';
import '../../cubits/workout_plan_cubit.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import '../../utilities/sizes/screen_size.dart';
import '../../widgets/layout/responsive_scaffold.dart';
import '../../widgets/workout_plan/details/workout_plan_header.dart';
import '../../widgets/workout_plan/editor/workout_plan_weeks_editor.dart';
import '../error_view.dart';
import '../loading_view.dart';

class WorkoutPlanEditView extends StatefulWidget {
  static const String name = 'workout_plan_edit';
  static const String routeName = '/workout-plans/:id/edit';

  final int workoutPlanId;

  const WorkoutPlanEditView({
    super.key,
    required this.workoutPlanId,
  });

  @override
  State<WorkoutPlanEditView> createState() => _WorkoutPlanEditViewState();
}

class _WorkoutPlanEditViewState extends State<WorkoutPlanEditView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkoutPlanCubit>();

    if (cubit.state.selectedWorkoutPlan?.id != widget.workoutPlanId) {
      cubit.getWorkoutPlan(widget.workoutPlanId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = BreakPoint.fromContext(context).screenSize;
    final sizes = DataDisplaySizes.getDataDisplaySizes(screenSize);
    final theme = Theme.of(context);
    final isDarkTheme = theme.colorScheme.brightness == Brightness.dark;

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
          showBackButton: false,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkoutPlanHeader(
                sizes: sizes,
                plan: plan,
              ),
              SizedBox(height: sizes.spacing * 1.25),
              Padding(
                padding: EdgeInsets.all(sizes.spacing / 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: sizes.spacing / 2),
                    Text(
                      'Weekly Breakdown',
                      style: TextStyle(
                        fontSize: sizes.titleFountSize,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkTheme ? Colors.grey[200] : Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: sizes.spacing),
                    WorkoutPlanWeeksEditor(
                      theme: theme,
                      sizes: sizes,
                      workoutPlanId: plan.id,
                      currentVersion: plan.currentVersion,
                      initialWeeks: plan.weeks ?? const [],
                      isLoading: state.isLoading,
                    ),
                  ],
                ),
              )
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
        }
      },
    );
  }
}
