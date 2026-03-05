import 'package:go_router/go_router.dart';

import '../views/active_workout_view.dart';
import '../views/create_profile_view.dart';
import '../views/workouts/workout_edit_view.dart';
import '../views/current_workout_plan_view.dart';
import '../views/equipments/equipment_creation_view.dart';
import '../views/equipments/equipment_details_view.dart';
import '../views/equipments/equipment_update_view.dart';
import '../views/equipments/equipments_view.dart';
import '../views/exercises/exercise_creation_view.dart';
import '../views/exercises/exercise_detail_view.dart';
import '../views/exercise_history_detail_view.dart';
import '../views/exercises/exercise_update_view.dart';
import '../views/exercises/exercises_view.dart';
import '../views/main_navigation_view.dart';
import '../views/not_found_view.dart';
import '../views/onboarding_view.dart';
import '../views/weight/weight_goal_view.dart';
import '../views/weight_log_view.dart';
import '../views/workouts/workout_detail_view.dart';
import '../views/workout_history_detail_view.dart';
import '../views/workout_history_view.dart';
import '../views/workout_plans/workout_plan_detail_view.dart';
import '../views/workout_plans/workout_plan_edit_view.dart';
import '../views/workout_plans/workout_plan_list_view.dart';
import '../views/workout_plan_progress_view.dart';
import '../views/workouts/workouts_view.dart';

sealed class AppRouter {
  static final List<GoRoute> _routes = <GoRoute>[
    GoRoute(
      path: MainNavigationView.routeName,
      builder: (context, state) => const MainNavigationView(),
    ),
    GoRoute(
      path: CreateProfileView.routeName,
      builder: (context, state) => const CreateProfileView(),
    ),
    GoRoute(
      path: OnboardingView.routeName,
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: WeightLogView.routeName,
      builder: (context, state) => const WeightLogView(),
    ),
    GoRoute(
      path: WeightGoalView.routeName,
      builder: (context, state) => const WeightGoalView(),
    ),
    GoRoute(
      path: EquipmentsView.routeName,
      builder: (context, state) => const EquipmentsView(),
    ),
    GoRoute(
      path: EquipmentCreationView.routeName,
      builder: (context, state) => const EquipmentCreationView(),
    ),
    GoRoute(
      path: EquipmentDetailsView.routeName,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return EquipmentDetailsView(equipmentId: id);
      },
    ),
    GoRoute(
      path: EquipmentUpdateView.routeName,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return EquipmentUpdateView(equipmentId: id);
      },
    ),
    GoRoute(
      path: ExercisesView.routeName,
      builder: (context, state) => const ExercisesView(),
    ),
    GoRoute(
      path: ExerciseCreationView.routeName,
      builder: (context, state) => const ExerciseCreationView(),
    ),
    GoRoute(
      path: ExerciseDetailView.routeName,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ExerciseDetailView(exerciseId: id);
      },
    ),
    GoRoute(
      path: ExerciseUpdateView.routeName,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ExerciseUpdateView(exerciseId: id);
      },
    ),
    GoRoute(
      path: WorkoutsView.routeName,
      builder: (context, state) => const WorkoutsView(),
    ),
    GoRoute(
      path: WorkoutEditView.routeName,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return WorkoutEditView(workoutId: id);
      },
    ),
    GoRoute(
      path: '/workouts/:id/history',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return WorkoutHistoryDetailView(workoutRecordId: id);
      },
    ),
    GoRoute(
      path: '/workouts/:id/active',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ActiveWorkoutView(workoutId: id);
      },
    ),
    GoRoute(
      path: WorkoutDetailView.routeName,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return WorkoutDetailView(workoutId: id);
      },
    ),
    GoRoute(
      path: WorkoutHistoryView.routeName,
      builder: (context, state) => const WorkoutHistoryView(),
    ),
    GoRoute(
      path: '/exercises/:id/history',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ExerciseHistoryDetailView(exerciseId: id);
      },
    ),
    GoRoute(
      path: WorkoutPlanListView.routeName,
      builder: (context, state) => const WorkoutPlanListView(),
    ),
    GoRoute(
      path: WorkoutPlanEditView.routeName,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return WorkoutPlanEditView(workoutPlanId: id);
      },
    ),
    GoRoute(
      path: '/workout-plans/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return WorkoutPlanDetailView(workoutPlanId: id);
      },
    ),
    GoRoute(
      path: CurrentWorkoutPlanView.routeName,
      builder: (context, state) => const CurrentWorkoutPlanView(),
    ),
    GoRoute(
      path: WorkoutPlanProgressView.routeName,
      builder: (context, state) => const WorkoutPlanProgressView(),
    ),
  ];

  static final GoRouter _router = GoRouter(
    routes: _routes,
    initialLocation: MainNavigationView.routeName,
    errorBuilder: (context, state) => const NotFoundView(),
  );

  static GoRouter get router => _router;
}
