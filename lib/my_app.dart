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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/data/repositories/exercises/exercise_record_repository.dart';
import 'src/data/repositories/exercises/exercise_repository.dart';
import 'src/data/repositories/foods/food_repository.dart';
import 'src/data/repositories/macros/macro_tracking_repository.dart';
import 'src/data/repositories/meal_plans/meal_plan_record_repository.dart';
import 'src/data/repositories/meal_plans/meal_plan_repository.dart';
import 'src/data/repositories/onboarding/onboarding_repository.dart';
import 'src/data/repositories/profile/profile_repository.dart';
import 'src/data/repositories/recipes/recipe_repository.dart';
import 'src/data/repositories/weight/weight_record_repository.dart';
import 'src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'src/data/repositories/workouts/workout_record_repository.dart';
import 'src/data/repositories/workouts/workout_repository.dart';
import 'src/routing/app_router.dart';
import 'src/ui/core/themes/theme_generator.dart';
import 'src/ui/exercises/view_models/exercise_cubit.dart';
import 'src/ui/exercises/view_models/exercise_record_cubit.dart';
import 'src/ui/foods/view_models/food_cubit.dart';
import 'src/ui/home/view_models/profile_cubit.dart';
import 'src/ui/home/view_models/states/profile_state.dart';
import 'src/ui/macros/view_models/macro_tracking_cubit.dart';
import 'src/ui/meal_plans/view_models/meal_plan_cubit.dart';
import 'src/ui/meal_plans/view_models/meal_plan_record_cubit.dart';
import 'src/ui/recipes/view_models/recipe_cubit.dart';
import 'src/ui/weight/view_models/weight_record_cubit.dart';
import 'src/ui/workout_plans/view_models/workout_plan_cubit.dart';
import 'src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'src/ui/workouts/view_models/active_workout_cubit.dart';
import 'src/ui/workouts/view_models/workout_cubit.dart';
import 'src/ui/workouts/view_models/workout_record_cubit.dart';

class MyApp extends StatelessWidget {
  final RouterConfig<Object>? routerConfig;

  const MyApp({super.key, this.routerConfig});

  @override
  Widget build(BuildContext context) {
    GoogleFonts.config.allowRuntimeFetching = false;

    final profileRepository = ProfileRepository.create();
    final exerciseRepository = ExerciseRepository.create();
    final exerciseRecordRepository = ExerciseRecordRepository.create();
    final weightRecordRepository = WeightRecordRepository.create();
    final workoutRepository = WorkoutRepository.create();
    final workoutRecordRepository = WorkoutRecordRepository.create();
    final workoutPlanRepository = WorkoutPlanRepository.create();
    final workoutPlanRecordRepository = WorkoutPlanRecordRepository.create();
    final foodRepository = FoodRepository.create();
    final recipeRepository = RecipeRepository.create();
    final macroTrackingRepository = MacroTrackingRepository.create();
    final mealPlanRepository = MealPlanRepository.create();
    final mealPlanRecordRepository = MealPlanRecordRepository.create();
    final onboardingRepository = OnboardingRepository.create(
      profileService: profileRepository,
      exerciseService: exerciseRepository,
      workoutService: workoutRepository,
      workoutPlanService: workoutPlanRepository,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(
          create: (BuildContext context) => ProfileCubit(
            profileRepository: profileRepository,
            onboardingService: onboardingRepository,
          )..loadInitialData(),
          lazy: false,
        ),
        BlocProvider<ExerciseCubit>(
          create: (BuildContext context) =>
              ExerciseCubit(exerciseRepository: exerciseRepository),
        ),
        BlocProvider<ExerciseRecordCubit>(
          create: (BuildContext context) => ExerciseRecordCubit(
            exerciseRecordRepository: exerciseRecordRepository,
          ),
        ),
        BlocProvider<WeightRecordCubit>(
          create: (BuildContext context) =>
              WeightRecordCubit(weightRecordRepository: weightRecordRepository),
        ),
        BlocProvider<WorkoutCubit>(
          create: (BuildContext context) =>
              WorkoutCubit(workoutRepository: workoutRepository),
        ),
        BlocProvider<WorkoutRecordCubit>(
          create: (BuildContext context) => WorkoutRecordCubit(
            workoutRecordRepository: workoutRecordRepository,
          ),
        ),
        BlocProvider<WorkoutPlanCubit>(
          create: (BuildContext context) =>
              WorkoutPlanCubit(workoutPlanRepository: workoutPlanRepository),
        ),
        BlocProvider<WorkoutPlanRecordCubit>(
          create: (BuildContext context) => WorkoutPlanRecordCubit(
            workoutPlanRecordRepository: workoutPlanRecordRepository,
            workoutPlanRepository: workoutPlanRepository,
          ),
        ),
        BlocProvider<ActiveWorkoutCubit>(
          create: (BuildContext context) => ActiveWorkoutCubit(
            workoutRepository: workoutRepository,
            workoutRecordRepository: workoutRecordRepository,
            workoutPlanRecordRepository: workoutPlanRecordRepository,
          ),
        ),
        BlocProvider<FoodCubit>(
          create: (BuildContext context) =>
              FoodCubit(foodRepository: foodRepository),
        ),
        BlocProvider<RecipeCubit>(
          create: (BuildContext context) =>
              RecipeCubit(recipeRepository: recipeRepository),
        ),
        BlocProvider<MacroTrackingCubit>(
          create: (BuildContext context) => MacroTrackingCubit(
            macroTrackingRepository: macroTrackingRepository,
          ),
        ),
        BlocProvider<MealPlanCubit>(
          create: (BuildContext context) =>
              MealPlanCubit(mealPlanRepository: mealPlanRepository),
        ),
        BlocProvider<MealPlanRecordCubit>(
          create: (BuildContext context) => MealPlanRecordCubit(
            mealPlanRecordRepository: mealPlanRecordRepository,
          ),
        ),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) {
          return previous.system?.theme != current.system?.theme;
        },
        builder: (context, state) {
          return MaterialApp.router(
            title: 'My Fitness Tale',
            theme: ThemeGenerator.themeFromContext(
              context,
              themeOverride: state.system?.theme,
            ),
            routerConfig: routerConfig ?? AppRouter.router,
          );
        },
      ),
    );
  }
}
