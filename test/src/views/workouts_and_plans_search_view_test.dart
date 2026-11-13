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
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workouts/workout_repository.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/core/widgets/created_by_checkbox.dart';
import 'package:myfitnesstale/src/ui/core/widgets/search_form_button.dart';
import 'package:myfitnesstale/src/ui/workout_plans/screens/workout_plan_list_screen.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/workouts/screens/workouts_screen.dart';
import 'package:myfitnesstale/src/ui/workouts/view_models/workout_cubit.dart';

class _SpyWorkoutPlanCubit extends WorkoutPlanCubit {
  final List<CreatedBy?> requestedCreatedBy = [];

  _SpyWorkoutPlanCubit()
    : super(workoutPlanRepository: WorkoutPlanRepository.create());

  @override
  Future<void> getWorkoutPlans({
    String? name,
    Difficulty? difficulty,
    bool isFavorite = false,
    CreatedBy? createdBy,
    int? limit,
    int? offset,
  }) async {
    requestedCreatedBy.add(createdBy);
  }
}

class _SpyWorkoutCubit extends WorkoutCubit {
  final List<CreatedBy?> requestedCreatedBy = [];

  _SpyWorkoutCubit() : super(workoutRepository: WorkoutRepository.create());

  @override
  Future<void> getWorkouts({
    String? name,
    Difficulty? difficulty,
    MuscleGroup? muscleGroup,
    int? limit,
    int? offset,
    bool isFavorite = false,
    CreatedBy? createdBy,
  }) async {
    requestedCreatedBy.add(createdBy);
  }
}

void main() {
  testWidgets(
    'WorkoutPlanListScreen toggles createdBy filter with person icon button',
    (tester) async {
      final cubit = _SpyWorkoutPlanCubit();
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: '/workout-plans',
        routes: [
          GoRoute(
            path: '/workout-plans',
            builder: (_, _) => const WorkoutPlanListScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<WorkoutPlanCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();

      expect(cubit.requestedCreatedBy, [null]);
      expect(find.byType(CreatedByCheckbox), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.text('All Muscle Groups'), findsNothing);

      await tester.tap(find.byType(CreatedByCheckbox));
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);

      await tester.tap(find.byType(SearchFormButton));
      await tester.pump();
      expect(cubit.requestedCreatedBy, [null, CreatedBy.user]);
    },
  );

  testWidgets(
    'WorkoutsScreen toggles createdBy filter with person icon button',
    (tester) async {
      final cubit = _SpyWorkoutCubit();
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: '/workouts',
        routes: [
          GoRoute(path: '/workouts', builder: (_, _) => const WorkoutsScreen()),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        BlocProvider<WorkoutCubit>.value(
          value: cubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();

      expect(cubit.requestedCreatedBy, [null]);
      expect(find.byType(CreatedByCheckbox), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.text('All Muscle Groups'), findsOneWidget);

      await tester.tap(find.byType(CreatedByCheckbox));
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);

      await tester.tap(find.byType(SearchFormButton));
      await tester.pump();
      expect(cubit.requestedCreatedBy, [null, CreatedBy.user]);
    },
  );
}
