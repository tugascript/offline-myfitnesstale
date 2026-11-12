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

import 'package:go_router/go_router.dart';

import '../ui/core/screens/not_found_screen.dart';
import '../ui/exercises/screens/equipment_creation_screen.dart';
import '../ui/exercises/screens/equipment_details_screen.dart';
import '../ui/exercises/screens/equipment_update_screen.dart';
import '../ui/exercises/screens/equipments_screen.dart';
import '../ui/exercises/screens/exercise_creation_screen.dart';
import '../ui/exercises/screens/exercise_detail_screen.dart';
import '../ui/exercises/screens/exercise_progress_screen.dart';
import '../ui/exercises/screens/exercise_records_screen.dart';
import '../ui/exercises/screens/exercise_update_screen.dart';
import '../ui/exercises/screens/exercises_screen.dart';
import '../ui/exercises/screens/strength_goals_screen.dart';
import '../ui/foods/screens/food_creation_screen.dart';
import '../ui/foods/screens/food_details_screen.dart';
import '../ui/foods/screens/food_update_screen.dart';
import '../ui/foods/screens/foods_screen.dart';
import '../ui/home/screens/main_navigation_screen.dart';
import '../ui/home/screens/profile/create_profile_screen.dart';
import '../ui/home/screens/profile/onboarding_screen.dart';
import '../ui/home/screens/profile/reminder_preferences_screen.dart';
import '../ui/macros/screens/macro_goals_screen.dart';
import '../ui/macros/screens/macro_tracker_screen.dart';
import '../ui/meal_plans/screens/meal_plan_creation_screen.dart';
import '../ui/meal_plans/screens/meal_plan_details_screen.dart';
import '../ui/meal_plans/screens/meal_plan_list_screen.dart';
import '../ui/meal_plans/screens/meal_plan_update_screen.dart';
import '../ui/recipes/screens/recipe_creation_screen.dart';
import '../ui/recipes/screens/recipe_details_screen.dart';
import '../ui/recipes/screens/recipe_update_screen.dart';
import '../ui/recipes/screens/recipes_screen.dart';
import '../ui/weight/screens/weight_goals_screen.dart';
import '../ui/weight/screens/weight_records_screen.dart';
import '../ui/workout_plans/screens/active_workout_plan_screen.dart';
import '../ui/workout_plans/screens/workout_plan_detail_screen.dart';
import '../ui/workout_plans/screens/workout_plan_edit_screen.dart';
import '../ui/workout_plans/screens/workout_plan_history_screen.dart';
import '../ui/workout_plans/screens/workout_plan_list_screen.dart';
import '../ui/workouts/screens/active_workout_screen.dart';
import '../ui/workouts/screens/create_workout_record_screen.dart';
import '../ui/workouts/screens/update_workout_record_screen.dart';
import '../ui/workouts/screens/workout_detail_screen.dart';
import '../ui/workouts/screens/workout_edit_screen.dart';
import '../ui/workouts/screens/workout_history_detail_screen.dart';
import '../ui/workouts/screens/workout_history_screen.dart';
import '../ui/workouts/screens/workouts_screen.dart';
import 'routes.dart';

sealed class AppRouter {
  static final List<GoRoute> _routes = <GoRoute>[
    GoRoute(
      path: Routes.home.name,
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: Routes.createProfile.name,
      builder: (context, state) => const CreateProfileScreen(),
    ),
    GoRoute(
      path: Routes.onboarding.name,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: Routes.weightGoal.name,
      builder: (context, state) => const WeightGoalScreen(),
    ),
    GoRoute(
      path: Routes.weightRecords.name,
      builder: (context, state) => const WeightRecordsScreen(),
    ),
    GoRoute(
      path: Routes.equipments.name,
      builder: (context, state) => const EquipmentsScreen(),
    ),
    GoRoute(
      path: Routes.equipmentCreation.name,
      builder: (context, state) => const EquipmentCreationScreen(),
    ),
    GoRoute(
      path: Routes.equipmentDetails.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return EquipmentDetailsScreen(equipmentId: id);
      },
    ),
    GoRoute(
      path: Routes.equipmentUpdate.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return EquipmentUpdateScreen(equipmentId: id);
      },
    ),
    GoRoute(
      path: Routes.exercises.name,
      builder: (context, state) => const ExercisesScreen(),
    ),
    GoRoute(
      path: Routes.exerciseCreation.name,
      builder: (context, state) => const ExerciseCreationScreen(),
    ),
    GoRoute(
      path: Routes.exerciseProgress.name,
      builder: (context, state) => const ExerciseProgressScreen(),
    ),
    GoRoute(
      path: Routes.exerciseDetail.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return ExerciseDetailScreen(exerciseId: id);
      },
    ),
    GoRoute(
      path: Routes.exerciseUpdate.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return ExerciseUpdateScreen(exerciseId: id);
      },
    ),
    GoRoute(
      path: Routes.workouts.name,
      builder: (context, state) => const WorkoutsScreen(),
    ),
    GoRoute(
      path: Routes.workoutEdit.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return WorkoutEditScreen(workoutId: id);
      },
    ),
    GoRoute(
      path: Routes.workoutHistory.name,
      builder: (context, state) {
        final idParam = state.uri.queryParameters['id'];
        int? workoutId;
        if (idParam != null) {
          workoutId = int.tryParse(idParam);
          if (workoutId == null) {
            return const NotFoundScreen();
          }
        }

        final versionParam = state.uri.queryParameters['version'];
        int? version;
        if (versionParam != null) {
          if (workoutId == null) {
            return const NotFoundScreen();
          }
          version = int.tryParse(versionParam);
          if (version == null) {
            return const NotFoundScreen();
          }
        }

        return WorkoutHistoryScreen(workoutId: workoutId, version: version);
      },
    ),
    GoRoute(
      path: Routes.createWorkoutRecord.name,
      builder: (context, state) {
        final workoutId = int.tryParse(state.pathParameters['id'] ?? '');
        if (workoutId == null) {
          return const NotFoundScreen();
        }

        final version = int.tryParse(state.pathParameters['version'] ?? '');
        if (version == null) {
          return const NotFoundScreen();
        }

        return CreateWorkoutRecordScreen(
          workoutId: workoutId,
          version: version,
          workoutPlanRecordId: int.tryParse(
            state.uri.queryParameters['workoutPlanRecordId'] ?? '',
          ),
          week: int.tryParse(state.uri.queryParameters['week'] ?? ''),
          day: int.tryParse(state.uri.queryParameters['day'] ?? ''),
          workoutPosition: int.tryParse(
            state.uri.queryParameters['workoutPosition'] ?? '',
          ),
        );
      },
    ),
    GoRoute(
      path: Routes.workoutHistoryDetail.name,
      builder: (context, state) {
        final workoutId = int.tryParse(state.pathParameters['workoutId'] ?? '');
        if (workoutId == null) {
          return const NotFoundScreen();
        }

        final version = int.tryParse(state.pathParameters['version'] ?? '');
        if (version == null) {
          return const NotFoundScreen();
        }

        final workoutRecordId = int.tryParse(
          state.pathParameters['workoutRecordId'] ?? '',
        );
        if (workoutRecordId == null) {
          return const NotFoundScreen();
        }
        return WorkoutHistoryDetailScreen(
          workoutId: workoutId,
          workoutRecordId: workoutRecordId,
          version: version,
        );
      },
    ),
    GoRoute(
      path: Routes.updateWorkoutRecord.name,
      builder: (context, state) {
        final workoutId = int.tryParse(state.pathParameters['workoutId'] ?? '');
        if (workoutId == null) {
          return const NotFoundScreen();
        }

        final version = int.tryParse(state.pathParameters['version'] ?? '');
        if (version == null) {
          return const NotFoundScreen();
        }

        final workoutRecordId = int.tryParse(
          state.pathParameters['workoutRecordId'] ?? '',
        );
        if (workoutRecordId == null) {
          return const NotFoundScreen();
        }

        return UpdateWorkoutRecordScreen(
          workoutId: workoutId,
          workoutRecordId: workoutRecordId,
          version: version,
        );
      },
    ),
    GoRoute(
      path: Routes.activeWorkout.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        final workoutPlanRecordId = int.tryParse(
          state.uri.queryParameters['workoutPlanRecordId'] ?? '',
        );
        final week = int.tryParse(state.uri.queryParameters['week'] ?? '');
        final day = int.tryParse(state.uri.queryParameters['day'] ?? '');
        final workoutPosition = int.tryParse(
          state.uri.queryParameters['workoutPosition'] ?? '',
        );
        return ActiveWorkoutScreen(
          workoutId: id,
          workoutPlanRecordId: workoutPlanRecordId,
          week: week,
          day: day,
          workoutPosition: workoutPosition,
        );
      },
    ),
    GoRoute(
      path: Routes.workoutDetail.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return WorkoutDetailScreen(workoutId: id);
      },
    ),
    GoRoute(
      path: Routes.exerciseRecords.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return ExerciseRecordsScreen(exerciseId: id);
      },
    ),
    GoRoute(
      path: Routes.workoutPlanList.name,
      builder: (context, state) => const WorkoutPlanListScreen(),
    ),
    GoRoute(
      path: Routes.workoutPlanHistory.name,
      builder: (context, state) {
        final idParam = state.uri.queryParameters['id'];
        int? id;
        if (idParam != null) {
          id = int.tryParse(idParam);
          if (id == null) {
            return const NotFoundScreen();
          }
        }

        final versionParam = state.uri.queryParameters['version'];
        int? version;
        if (versionParam != null) {
          if (id == null) {
            return const NotFoundScreen();
          }
          version = int.tryParse(versionParam);
          if (version == null) {
            return const NotFoundScreen();
          }
        }

        return WorkoutPlanHistoryScreen(workoutPlanId: id, version: version);
      },
    ),
    GoRoute(
      path: Routes.workoutPlanEdit.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return WorkoutPlanEditScreen(workoutPlanId: id);
      },
    ),
    GoRoute(
      path: Routes.activeWorkoutPlan.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return ActiveWorkoutPlanScreen(workoutPlanId: id);
      },
    ),
    GoRoute(
      path: Routes.workoutPlanDetail.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return WorkoutPlanDetailScreen(workoutPlanId: id);
      },
    ),
    GoRoute(
      path: Routes.reminderPreferences.name,
      builder: (context, state) => const ReminderPreferencesScreen(),
    ),
    // Strength Goals
    GoRoute(
      path: Routes.strengthGoals.name,
      builder: (context, state) => const StrengthGoalsScreen(),
    ),
    // Foods (static before dynamic)
    GoRoute(
      path: Routes.foods.name,
      builder: (context, state) => const FoodsScreen(),
    ),
    GoRoute(
      path: Routes.foodCreation.name,
      builder: (context, state) => const FoodCreationScreen(),
    ),
    GoRoute(
      path: Routes.foodUpdate.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return FoodUpdateScreen(foodId: id);
      },
    ),
    GoRoute(
      path: Routes.foodDetails.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return FoodDetailsScreen(foodId: id);
      },
    ),
    // Recipes (static before dynamic)
    GoRoute(
      path: Routes.recipes.name,
      builder: (context, state) => const RecipesScreen(),
    ),
    GoRoute(
      path: Routes.recipeCreation.name,
      builder: (context, state) => const RecipeCreationScreen(),
    ),
    GoRoute(
      path: Routes.recipeUpdate.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return RecipeUpdateScreen(recipeId: id);
      },
    ),
    GoRoute(
      path: Routes.recipeDetails.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return RecipeDetailsScreen(recipeId: id);
      },
    ),
    // Macro Goals & Tracker
    GoRoute(
      path: Routes.macroGoals.name,
      builder: (context, state) => const MacroGoalsScreen(),
    ),
    GoRoute(
      path: Routes.macroTracker.name,
      builder: (context, state) => const MacroTrackerScreen(),
    ),
    // Meal Plans (static before dynamic)
    GoRoute(
      path: Routes.mealPlanList.name,
      builder: (context, state) => const MealPlanListScreen(),
    ),
    GoRoute(
      path: Routes.mealPlanCreation.name,
      builder: (context, state) => const MealPlanCreationScreen(),
    ),
    GoRoute(
      path: Routes.mealPlanUpdate.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return MealPlanUpdateScreen(mealPlanId: id);
      },
    ),
    GoRoute(
      path: Routes.mealPlanDetails.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundScreen();
        }
        return MealPlanDetailsScreen(mealPlanId: id);
      },
    ),
  ];

  static GoRouter createRouter({String? initialLocation}) {
    return GoRouter(
      routes: _routes,
      initialLocation: initialLocation ?? Routes.home.name,
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }

  static final GoRouter _router = createRouter();

  static GoRouter get router => _router;
}
