import 'package:go_router/go_router.dart';

import '../views/active_workout_view.dart';
import '../views/create_profile_view.dart';
import '../views/create_workout_view.dart';
import '../views/current_workout_plan_view.dart';
import '../views/exercise_detail_view.dart';
import '../views/exercise_form_view.dart';
import '../views/exercise_history_detail_view.dart';
import '../views/exercise_library_view.dart';
import '../views/main_navigation_view.dart';
import '../views/not_found_view.dart';
import '../views/onboarding_view.dart';
import '../views/settings_view.dart';
import '../views/weight_goal_view.dart';
import '../views/weight_log_view.dart';
import '../views/workout_detail_view.dart';
import '../views/workout_history_detail_view.dart';
import '../views/workout_history_view.dart';
import '../views/workout_plan_detail_view.dart';
import '../views/workout_plan_list_view.dart';
import '../views/workout_plan_progress_view.dart';
import '../views/workouts_view.dart';

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
      path: SettingsView.routeName,
      builder: (context, state) => const SettingsView(),
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
      path: ExerciseLibraryView.routeName,
      builder: (context, state) => const ExerciseLibraryView(),
    ),
    GoRoute(
      path: '/exercises/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ExerciseDetailView(exerciseId: id);
      },
    ),
    GoRoute(
      path: ExerciseFormView.routeName,
      builder: (context, state) => const ExerciseFormView(),
    ),
    GoRoute(
      path: '/exercises/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ExerciseFormView(exerciseId: id);
      },
    ),
    GoRoute(
      path: WorkoutsView.routeName,
      builder: (context, state) => const WorkoutsView(),
    ),
    GoRoute(
      path: '/workouts/create',
      builder: (context, state) => const CreateWorkoutView(),
    ),
    GoRoute(
      path: '/workouts/history/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return WorkoutHistoryDetailView(workoutRecordId: id);
      },
    ),
    GoRoute(
      path: '/workouts/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return CreateWorkoutView(workoutId: id); // TODO: fix me
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

  static GoRouter get router => GoRouter(
        routes: _routes,
        initialLocation: MainNavigationView.routeName,
        errorBuilder: (context, state) => const NotFoundView(),
      );
}
