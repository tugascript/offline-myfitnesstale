import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../view_models/states/workout_plan_state.dart';
import '../view_models/states/workout_plan_record_state.dart';
import '../view_models/workout_plan_cubit.dart';
import '../view_models/workout_plan_record_cubit.dart';
import '../../../data/utils/enums.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../core/widgets/action_buttons.dart';
import '../widgets/details/workout_plan_header.dart';
import '../widgets/details/workout_plan_week_card.dart';
import '../../core/screens/loading_screen.dart';
import './workout_plan_history_screen.dart';

class WorkoutPlanDetailScreen extends StatefulWidget {
  static const String name = 'workout-plan-detail';

  final int workoutPlanId;

  const WorkoutPlanDetailScreen({super.key, required this.workoutPlanId});

  @override
  State<WorkoutPlanDetailScreen> createState() =>
      _WorkoutPlanDetailScreenState();
}

class _WorkoutPlanDetailScreenState extends State<WorkoutPlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutPlanCubit>().getWorkoutPlan(widget.workoutPlanId);
    final recordCubit = context.read<WorkoutPlanRecordCubit>();
    if (!recordCubit.state.isLoading &&
        recordCubit.state.currentPlanRecord.workoutPlan == null) {
      recordCubit.getLatestActivePlanRecord();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final breakpoints = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakpoints.screenSize);

    return BlocConsumer<WorkoutPlanCubit, WorkoutPlanState>(
      builder: (context, state) {
        if (state.isLoading && state.selectedWorkoutPlan == null) {
          return LoadingScreen(
            title: "Workout Plan details",
            message: "Loading workout plan details...",
          );
        }

        if (state.selectedWorkoutPlan == null) {
          return AppScaffold(
            title: "Unknown Workout Plan",
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    state.error?.description ?? 'Workout plan not found',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final plan = state.selectedWorkoutPlan!;

        return ResponsiveScaffold(
          title: plan.name,
          isEntity: true,
          body: Padding(
            padding: EdgeInsets.all(sizes.viewPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Header
                WorkoutPlanHeader(
                  actionButtonPress: () {
                    context.read<WorkoutPlanCubit>().updateWorkoutPlanFavorite(
                      plan.id,
                      !plan.isFavorite,
                    );
                  },
                  sizes: sizes,
                  plan: plan,
                ),
                SizedBox(height: sizes.spacing * 1.25),
                // Weekly Breakdown
                Text(
                  'Weekly Breakdown',
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.grey[200] : Colors.grey[800],
                  ),
                ),
                SizedBox(height: sizes.spacing),
                ...(plan.weeks?.asMap().entries.map(
                      (entry) => WorkoutPlanWeekCard(
                        theme: theme,
                        isDarkTheme: isDarkTheme,
                        sizes: sizes,
                        week: entry.value,
                        weekNumber: entry.key + 1,
                      ),
                    ) ??
                    []),
                SizedBox(height: sizes.spacing),
                BlocBuilder<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
                  builder: (context, recordState) {
                    final isActive =
                        recordState.currentPlanRecord.workoutPlan?.id ==
                        plan.id;
                    return ActionButtons(
                      isLoading: state.isLoading || recordState.isLoading,
                      showMutationBtns: plan.createdBy == CreatedBy.user,
                      theme: theme,
                      sizes: sizes,
                      onStart: () =>
                          context.push('/workout-plans/${plan.id}/active'),
                      startLabel: isActive ? 'Continue Plan' : 'Start Plan',
                      onEdit: () =>
                          context.push('/workout-plans/${plan.id}/edit'),
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmationDialog(
                            title: 'Delete Workout Plan',
                            content: 'Are you sure you want to delete this workout plan? This action cannot be undone.',
                            onConfirm: () async {
                              await context
                                  .read<WorkoutPlanCubit>()
                                  .deleteWorkoutPlan(plan.id);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        );
                      },
                      onHistory: () => context.push(
                        WorkoutPlanHistoryScreen.location(plan.id),
                      ),
                      historyLabel: 'Plan History',
                    );
                  },
                ),
              ],
            ),
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
