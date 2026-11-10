import 'package:go_router/go_router.dart';

import '../ui/exercises/screens/equipment_creation_view.dart';
import '../ui/exercises/screens/equipment_details_view.dart';
import '../ui/exercises/screens/equipment_update_view.dart';
import '../ui/exercises/screens/equipments_view.dart';
import '../ui/exercises/screens/exercise_creation_view.dart';
import '../ui/exercises/screens/exercise_detail_view.dart';
import '../ui/exercises/screens/exercise_progress_view.dart';
import '../ui/exercises/screens/exercise_records_view.dart';
import '../ui/exercises/screens/exercise_update_view.dart';
import '../ui/exercises/screens/exercises_view.dart';
import '../ui/exercises/screens/strength_goals_view.dart';
import '../ui/home/screens/profile/create_profile_view.dart';
import '../ui/foods/screens/food_creation_view.dart';
import '../ui/foods/screens/food_details_view.dart';
import '../ui/foods/screens/food_update_view.dart';
import '../ui/foods/screens/foods_view.dart';
import '../ui/home/screens/main_navigation_view.dart';
import '../ui/macros/screens/macro_goals_view.dart';
import '../ui/macros/screens/macro_tracker_view.dart';
import '../ui/meal_plans/screens/meal_plan_creation_view.dart';
import '../ui/meal_plans/screens/meal_plan_details_view.dart';
import '../ui/meal_plans/screens/meal_plan_list_view.dart';
import '../ui/meal_plans/screens/meal_plan_update_view.dart';
import '../ui/core/screens/not_found_view.dart';
import '../ui/home/screens/profile/onboarding_view.dart';
import '../ui/home/screens/profile/reminder_preferences_view.dart';
import '../ui/recipes/screens/recipe_creation_view.dart';
import '../ui/recipes/screens/recipe_details_view.dart';
import '../ui/recipes/screens/recipe_update_view.dart';
import '../ui/recipes/screens/recipes_view.dart';
import '../ui/weight/screens/weight_goals_view.dart';
import '../ui/weight/screens/weight_records_view.dart';
import '../ui/workout_plans/screens/active_workout_plan_view.dart';
import '../ui/workout_plans/screens/workout_plan_detail_view.dart';
import '../ui/workout_plans/screens/workout_plan_edit_view.dart';
import '../ui/workout_plans/screens/workout_plan_history_view.dart';
import '../ui/workout_plans/screens/workout_plan_list_view.dart';
import '../ui/workouts/screens/active_workout_view.dart';
import '../ui/workouts/screens/create_workout_record_view.dart';
import '../ui/workouts/screens/update_workout_record_view.dart';
import '../ui/workouts/screens/workout_detail_view.dart';
import '../ui/workouts/screens/workout_edit_view.dart';
import '../ui/workouts/screens/workout_history_detail_view.dart';
import '../ui/workouts/screens/workout_history_view.dart';
import '../ui/workouts/screens/workouts_view.dart';
import './routing.dart';

sealed class AppRouter {
  static final List<GoRoute> _routes = <GoRoute>[
    GoRoute(
      path: Routes.home.name,
      builder: (context, state) => const MainNavigationView(),
    ),
    GoRoute(
      path: Routes.createProfile.name,
      builder: (context, state) => const CreateProfileView(),
    ),
    GoRoute(
      path: Routes.onboarding.name,
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: Routes.weightGoal.name,
      builder: (context, state) => const WeightGoalView(),
    ),
    GoRoute(
      path: Routes.weightRecords.name,
      builder: (context, state) => const WeightRecordsView(),
    ),
    GoRoute(
      path: Routes.equipments.name,
      builder: (context, state) => const EquipmentsView(),
    ),
    GoRoute(
      path: Routes.equipmentCreation.name,
      builder: (context, state) => const EquipmentCreationView(),
    ),
    GoRoute(
      path: Routes.equipmentDetails.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return EquipmentDetailsView(equipmentId: id);
      },
    ),
    GoRoute(
      path: Routes.equipmentUpdate.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return EquipmentUpdateView(equipmentId: id);
      },
    ),
    GoRoute(
      path: Routes.exercises.name,
      builder: (context, state) => const ExercisesView(),
    ),
    GoRoute(
      path: Routes.exerciseCreation.name,
      builder: (context, state) => const ExerciseCreationView(),
    ),
    GoRoute(
      path: Routes.exerciseProgress.name,
      builder: (context, state) => const ExerciseProgressView(),
    ),
    GoRoute(
      path: Routes.exerciseDetail.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ExerciseDetailView(exerciseId: id);
      },
    ),
    GoRoute(
      path: Routes.exerciseUpdate.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ExerciseUpdateView(exerciseId: id);
      },
    ),
    GoRoute(
      path: Routes.workouts.name,
      builder: (context, state) => const WorkoutsView(),
    ),
    GoRoute(
      path: Routes.workoutEdit.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return WorkoutEditView(workoutId: id);
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
            return const NotFoundView();
          }
        }

        final versionParam = state.uri.queryParameters['version'];
        int? version;
        if (versionParam != null) {
          if (workoutId == null) {
            return const NotFoundView();
          }
          version = int.tryParse(versionParam);
          if (version == null) {
            return const NotFoundView();
          }
        }

        return WorkoutHistoryView(workoutId: workoutId, version: version);
      },
    ),
    GoRoute(
      path: Routes.createWorkoutRecord.name,
      builder: (context, state) {
        final workoutId = int.tryParse(state.pathParameters['id'] ?? '');
        if (workoutId == null) {
          return const NotFoundView();
        }

        final version = int.tryParse(state.pathParameters['version'] ?? '');
        if (version == null) {
          return const NotFoundView();
        }

        return CreateWorkoutRecordView(
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
          return const NotFoundView();
        }

        final version = int.tryParse(state.pathParameters['version'] ?? '');
        if (version == null) {
          return const NotFoundView();
        }

        final workoutRecordId = int.tryParse(
          state.pathParameters['workoutRecordId'] ?? '',
        );
        if (workoutRecordId == null) {
          return const NotFoundView();
        }
        return WorkoutHistoryDetailView(
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
          return const NotFoundView();
        }

        final version = int.tryParse(state.pathParameters['version'] ?? '');
        if (version == null) {
          return const NotFoundView();
        }

        final workoutRecordId = int.tryParse(
          state.pathParameters['workoutRecordId'] ?? '',
        );
        if (workoutRecordId == null) {
          return const NotFoundView();
        }

        return UpdateWorkoutRecordView(
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
          return const NotFoundView();
        }
        final workoutPlanRecordId = int.tryParse(
          state.uri.queryParameters['workoutPlanRecordId'] ?? '',
        );
        final week = int.tryParse(state.uri.queryParameters['week'] ?? '');
        final day = int.tryParse(state.uri.queryParameters['day'] ?? '');
        final workoutPosition = int.tryParse(
          state.uri.queryParameters['workoutPosition'] ?? '',
        );
        return ActiveWorkoutView(
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
          return const NotFoundView();
        }
        return WorkoutDetailView(workoutId: id);
      },
    ),
    GoRoute(
      path: Routes.exerciseRecords.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ExerciseRecordsView(exerciseId: id);
      },
    ),
    GoRoute(
      path: Routes.workoutPlanList.name,
      builder: (context, state) => const WorkoutPlanListView(),
    ),
    GoRoute(
      path: Routes.workoutPlanHistory.name,
      builder: (context, state) {
        final idParam = state.uri.queryParameters['id'];
        int? id;
        if (idParam != null) {
          id = int.tryParse(idParam);
          if (id == null) {
            return const NotFoundView();
          }
        }
        return WorkoutPlanHistoryView(workoutPlanId: id);
      },
    ),
    GoRoute(
      path: Routes.workoutPlanEdit.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return WorkoutPlanEditView(workoutPlanId: id);
      },
    ),
    GoRoute(
      path: Routes.activeWorkoutPlan.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ActiveWorkoutPlanView(workoutPlanId: id);
      },
    ),
    GoRoute(
      path: Routes.workoutPlanDetail.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return WorkoutPlanDetailView(workoutPlanId: id);
      },
    ),
    GoRoute(
      path: Routes.reminderPreferences.name,
      builder: (context, state) => const ReminderPreferencesView(),
    ),
    // Strength Goals
    GoRoute(
      path: Routes.strengthGoals.name,
      builder: (context, state) => const StrengthGoalsView(),
    ),
    // Foods (static before dynamic)
    GoRoute(
      path: Routes.foods.name,
      builder: (context, state) => const FoodsView(),
    ),
    GoRoute(
      path: Routes.foodCreation.name,
      builder: (context, state) => const FoodCreationView(),
    ),
    GoRoute(
      path: Routes.foodUpdate.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return FoodUpdateView(foodId: id);
      },
    ),
    GoRoute(
      path: Routes.foodDetails.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return FoodDetailsView(foodId: id);
      },
    ),
    // Recipes (static before dynamic)
    GoRoute(
      path: Routes.recipes.name,
      builder: (context, state) => const RecipesView(),
    ),
    GoRoute(
      path: Routes.recipeCreation.name,
      builder: (context, state) => const RecipeCreationView(),
    ),
    GoRoute(
      path: Routes.recipeUpdate.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return RecipeUpdateView(recipeId: id);
      },
    ),
    GoRoute(
      path: Routes.recipeDetails.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return RecipeDetailsView(recipeId: id);
      },
    ),
    // Macro Goals & Tracker
    GoRoute(
      path: Routes.macroGoals.name,
      builder: (context, state) => const MacroGoalsView(),
    ),
    GoRoute(
      path: Routes.macroTracker.name,
      builder: (context, state) => const MacroTrackerView(),
    ),
    // Meal Plans (static before dynamic)
    GoRoute(
      path: Routes.mealPlanList.name,
      builder: (context, state) => const MealPlanListView(),
    ),
    GoRoute(
      path: Routes.mealPlanCreation.name,
      builder: (context, state) => const MealPlanCreationView(),
    ),
    GoRoute(
      path: Routes.mealPlanUpdate.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return MealPlanUpdateView(mealPlanId: id);
      },
    ),
    GoRoute(
      path: Routes.mealPlanDetails.name,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return MealPlanDetailsView(mealPlanId: id);
      },
    ),
  ];

  static GoRouter createRouter({String? initialLocation}) {
    return GoRouter(
      routes: _routes,
      initialLocation: initialLocation ?? Routes.home.name,
      errorBuilder: (context, state) => const NotFoundView(),
    );
  }

  static final GoRouter _router = createRouter();

  static GoRouter get router => _router;
}
