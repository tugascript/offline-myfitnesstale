import 'package:go_router/go_router.dart';

import '../views/create_profile_view.dart';
import '../views/equipments/equipment_creation_view.dart';
import '../views/equipments/equipment_details_view.dart';
import '../views/equipments/equipment_update_view.dart';
import '../views/equipments/equipments_view.dart';
import '../views/exercises/exercise_creation_view.dart';
import '../views/exercises/exercise_detail_view.dart';
import '../views/exercises/exercise_records_view.dart';
import '../views/exercises/exercise_update_view.dart';
import '../views/exercises/exercises_view.dart';
import '../views/home/main_navigation_view.dart';
import '../views/not_found_view.dart';
import '../views/onboarding_view.dart';
import '../views/weight/weight_goals_view.dart';
import '../views/weight/weight_records_view.dart';
import '../views/workout_plans/active_workout_plan_view.dart';
import '../views/workout_plans/workout_plan_detail_view.dart';
import '../views/workout_plans/workout_plan_edit_view.dart';
import '../views/workout_plans/workout_plan_list_view.dart';
import '../views/workouts/active_workout_view.dart';
import '../views/workouts/create_workout_record_view.dart';
import '../views/workouts/update_workout_record_view.dart';
import '../views/workouts/workout_detail_view.dart';
import '../views/workouts/workout_edit_view.dart';
import '../views/workouts/workout_history_detail_view.dart';
import '../views/workouts/workout_history_view.dart';
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
      path: WeightGoalView.routeName,
      builder: (context, state) => const WeightGoalView(),
    ),
    GoRoute(
      path: WeightRecordsView.routeName,
      builder: (context, state) => const WeightRecordsView(),
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
      path: WorkoutHistoryView.routeName,
      builder: (context, state) {
        final workoutId = int.tryParse(state.pathParameters['id'] ?? '');
        if (workoutId == null) {
          return const NotFoundView();
        }

        final version = int.tryParse(state.pathParameters['version'] ?? '');
        if (version == null) {
          return const NotFoundView();
        }

        return WorkoutHistoryView(workoutId: workoutId, version: version);
      },
    ),
    GoRoute(
        path: CreateWorkoutRecordView.routeName,
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
          );
        }),
    GoRoute(
      path: WorkoutHistoryDetailView.routeName,
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
      path: UpdateWorkoutRecordView.routeName,
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
      path: ActiveWorkoutView.routeName,
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
      path: '/exercises/:id/records',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ExerciseRecordsView(exerciseId: id);
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
      path: ActiveWorkoutPlanView.routeName,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return ActiveWorkoutPlanView(workoutPlanId: id);
      },
    ),
    GoRoute(
      path: WorkoutPlanDetailView.routeName,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const NotFoundView();
        }
        return WorkoutPlanDetailView(workoutPlanId: id);
      },
    ),
  ];

  static final GoRouter _router = GoRouter(
    routes: _routes,
    initialLocation: MainNavigationView.routeName,
    errorBuilder: (context, state) => const NotFoundView(),
  );

  static GoRouter get router => _router;
}
