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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../data/repositories/workout_plans/dtos/workout_plan_day_dto.dart';
import '../../../data/repositories/workout_plans/dtos/workout_plan_dto.dart';
import '../../../data/repositories/workout_plans/dtos/workout_plan_week_dto.dart';
import '../../../data/repositories/workout_plans/dtos/workout_plan_workout_dto.dart';
import '../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../data/utils/enums.dart';
import '../../../data/utils/json_data.dart';
import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/action_buttons.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/layout/app_scaffold.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../view_models/states/workout_plan_record_state.dart';
import '../view_models/states/workout_plan_state.dart';
import '../view_models/workout_plan_cubit.dart';
import '../view_models/workout_plan_record_cubit.dart';
import '../widgets/details/workout_plan_header.dart';
import '../widgets/details/workout_plan_schedule_card.dart';
import './workout_plan_history_screen.dart';

const _skeletonWorkout = WorkoutDto(
  id: 0,
  name: 'Loading Workout Name...',
  muscleGroups: {},
  muscles: TargetMuscles(primary: {}, secondary: {}),
  difficulty: Difficulty.beginner,
  version: 1,
  isFavorite: false,
  totalSets: 3,
  totalReps: 30,
  editorType: EditorType.advanced,
  createdBy: CreatedBy.system,
);

const _skeletonPlanWorkout = WorkoutPlanWorkoutDto(
  id: 0,
  planVersion: 1,
  position: 1,
  workoutId: 0,
  workout: _skeletonWorkout,
);

const _skeletonDays = [
  WorkoutPlanDayDto(
    id: 0,
    planVersion: 1,
    day: 1,
    totalWorkouts: 1,
    isRestDay: false,
    planWorkouts: [_skeletonPlanWorkout],
  ),
  WorkoutPlanDayDto(
    id: 0,
    planVersion: 1,
    day: 2,
    totalWorkouts: 1,
    isRestDay: false,
    planWorkouts: [_skeletonPlanWorkout],
  ),
  WorkoutPlanDayDto(
    id: 0,
    planVersion: 1,
    day: 3,
    totalWorkouts: 0,
    isRestDay: true,
    planWorkouts: [],
  ),
  WorkoutPlanDayDto(
    id: 0,
    planVersion: 1,
    day: 4,
    totalWorkouts: 1,
    isRestDay: false,
    planWorkouts: [_skeletonPlanWorkout],
  ),
  WorkoutPlanDayDto(
    id: 0,
    planVersion: 1,
    day: 5,
    totalWorkouts: 1,
    isRestDay: false,
    planWorkouts: [_skeletonPlanWorkout],
  ),
  WorkoutPlanDayDto(
    id: 0,
    planVersion: 1,
    day: 6,
    totalWorkouts: 0,
    isRestDay: true,
    planWorkouts: [],
  ),
  WorkoutPlanDayDto(
    id: 0,
    planVersion: 1,
    day: 7,
    totalWorkouts: 0,
    isRestDay: true,
    planWorkouts: [],
  ),
];

const _skeletonWorkoutPlan = WorkoutPlanDto(
  id: 0,
  name: 'Loading Workout Plan...',
  description: 'Loading workout plan description placeholder...',
  currentVersion: 1,
  totalWeeks: 2,
  totalDays: 14,
  totalWorkouts: 8,
  difficulty: Difficulty.beginner,
  isFavorite: false,
  createdBy: CreatedBy.system,
  weeks: [
    WorkoutPlanWeekDto(
      id: 0,
      planVersion: 1,
      startWeek: 1,
      endWeek: 1,
      totalDays: 7,
      totalWorkouts: 4,
      scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
      days: _skeletonDays,
    ),
    WorkoutPlanWeekDto(
      id: 0,
      planVersion: 1,
      startWeek: 2,
      endWeek: 2,
      totalDays: 7,
      totalWorkouts: 4,
      scheduleMode: WorkoutPlanWeekScheduleMode.automatic,
      days: _skeletonDays,
    ),
  ],
);

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
        final isSkeletonLoading =
            state.isLoading &&
            (state.selectedWorkoutPlan == null ||
                state.selectedWorkoutPlan!.id != widget.workoutPlanId);

        if (!isSkeletonLoading &&
            (state.selectedWorkoutPlan == null ||
                state.selectedWorkoutPlan!.id != widget.workoutPlanId)) {
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

        final plan = isSkeletonLoading
            ? _skeletonWorkoutPlan
            : state.selectedWorkoutPlan!;

        return ResponsiveScaffold(
          title: isSkeletonLoading ? 'Workout Plan details' : plan.name,
          isEntity: !isSkeletonLoading,
          body: Skeletonizer(
            enabled: isSkeletonLoading,
            child: Padding(
              padding: EdgeInsets.all(sizes.viewPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Header
                  WorkoutPlanHeader(
                    actionButtonPress: () {
                      final cubit = context.read<WorkoutPlanCubit>();
                      if (cubit.state.isLoading) return;
                      cubit.updateWorkoutPlanFavorite(
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
                  if (plan.weeks != null && plan.weeks!.isNotEmpty)
                    WorkoutPlanScheduleCard(
                      theme: theme,
                      isDarkTheme: isDarkTheme,
                      sizes: sizes,
                      weeks: plan.weeks!,
                    ),
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
