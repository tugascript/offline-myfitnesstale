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
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/sizes/data_display_sizes.dart';
import '../../core/sizes/screen_size.dart';
import '../../core/widgets/layout/responsive_scaffold.dart';
import '../../macros/view_models/macro_tracking_cubit.dart';
import '../../macros/view_models/states/macro_tracking_state.dart';
import '../../meal_plans/view_models/meal_plan_record_cubit.dart';
import '../../meal_plans/view_models/states/meal_plan_record_state.dart';
import '../../workout_plans/view_models/states/workout_plan_record_state.dart';
import '../../workout_plans/view_models/workout_plan_record_cubit.dart';
import '../view_models/profile_cubit.dart';
import '../view_models/states/profile_state.dart';
import '../widgets/active/active_plans_carousel.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/welcome_section.dart';

class HomeScreen extends StatefulWidget {
  static const name = "home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasAttemptedWorkoutLoad = false;
  bool _hasAttemptedMacroLoad = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadActiveDataIfNeeded(context.read<ProfileCubit>().state);
    });
  }

  void _loadActiveDataIfNeeded(ProfileState profileState) {
    if (profileState.profile == null || profileState.isLoading) {
      return;
    }

    if (!_hasAttemptedWorkoutLoad) {
      final workoutPlanCubit = context.read<WorkoutPlanRecordCubit>();
      final workoutState = workoutPlanCubit.state;
      if (!workoutState.isLoading &&
          !workoutState.hasLoadedActivePlan &&
          workoutState.currentPlanRecord.workoutPlan == null) {
        _hasAttemptedWorkoutLoad = true;
        workoutPlanCubit.getLatestActivePlanRecord();
      } else if (workoutState.hasLoadedActivePlan ||
          workoutState.currentPlanRecord.workoutPlan != null) {
        _hasAttemptedWorkoutLoad = true;
      }
    }

    if (!_hasAttemptedMacroLoad) {
      final macroCubit = context.read<MacroTrackingCubit>();
      final macroState = macroCubit.state;
      if (!macroState.isLoading &&
          !macroState.hasLoadedActiveGoal &&
          macroState.activeGoal == null) {
        _hasAttemptedMacroLoad = true;
        macroCubit.getActiveMacroGoal();
      } else if (macroState.hasLoadedActiveGoal ||
          macroState.activeGoal != null) {
        _hasAttemptedMacroLoad = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakPoint = BreakPoint.fromContext(context);
    final sizes = DataDisplaySizes.getDataDisplaySizes(breakPoint.screenSize);

    return ResponsiveScaffold(
      title: "My Fitness Tale",
      showBackButton: false,
      body: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            previous.profile != current.profile ||
            previous.isLoading != current.isLoading,
        listener: (context, profileState) {
          _loadActiveDataIfNeeded(profileState);
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            return BlocBuilder<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
              builder: (context, workoutPlanState) {
                return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
                  builder: (context, macroState) {
                    return BlocBuilder<
                      MealPlanRecordCubit,
                      MealPlanRecordState
                    >(
                      builder: (context, mealPlanState) {
                        final isProfileSkeleton =
                            !profileState.isInitiated ||
                            profileState.profile == null;
                        final isWorkoutSkeleton =
                            workoutPlanState.isLoading &&
                            workoutPlanState.currentPlanRecord.workoutPlan ==
                                null;
                        final isNutritionSkeleton =
                            (macroState.isLoading &&
                                macroState.activeGoal == null) ||
                            (mealPlanState.isLoading &&
                                mealPlanState.activeRecord == null);
                        final isLoading =
                            isProfileSkeleton ||
                            isWorkoutSkeleton ||
                            isNutritionSkeleton;

                        return Skeletonizer(
                          enabled: isLoading,
                          child: Container(
                            padding: EdgeInsets.all(sizes.viewPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Welcome Section
                                WelcomeSection(sizes: sizes),
                                SizedBox(height: sizes.betweenSpacing),

                                // Active workout and meal plans
                                ActivePlansCarousel(theme: theme, sizes: sizes),
                                SizedBox(height: sizes.betweenSpacing),

                                // Quick Actions
                                QuickActionsWidget(theme: theme, sizes: sizes),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
