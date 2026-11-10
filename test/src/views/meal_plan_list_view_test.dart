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
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:myfitnesstale/src/ui/meal_plans/view_models/meal_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/meal_plans/view_models/meal_plan_record_cubit.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/routing/routes.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/dtos/meal_plan_dto.dart';
import 'package:myfitnesstale/src/ui/meal_plans/screens/meal_plan_list_screen.dart';
import 'package:myfitnesstale/src/ui/core/widgets/favourite_checkbox.dart';
import 'package:myfitnesstale/src/ui/core/widgets/search_favorite_form.dart';
import 'package:myfitnesstale/src/ui/core/widgets/search_form_button.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_record_repository.dart';

class _FakeMealPlanCubit extends MealPlanCubit {
  int? toggledId;
  String? lastSearch;
  bool? lastIsFavorite;

  _FakeMealPlanCubit(List<MealPlanDto> plans)
    : super(mealPlanRepository: MealPlanRepository.create()) {
    emit(state.copyWith(mealPlans: plans));
  }

  @override
  Future<void> getMealPlans({
    String? search,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {
    lastSearch = search;
    lastIsFavorite = isFavorite;
  }

  @override
  Future<bool> toggleFavorite(int id) async {
    toggledId = id;
    final updated = state.mealPlans.map((p) {
      if (p.id == id) {
        return MealPlanDto(
          id: p.id,
          name: p.name,
          description: p.description,
          version: p.version,
          totalWeeks: p.totalWeeks,
          totalDays: p.totalDays,
          totalMeals: p.totalMeals,
          isFavorite: !p.isFavorite,
          createdBy: p.createdBy,
          weeks: p.weeks,
        );
      }
      return p;
    }).toList();
    emit(state.copyWith(mealPlans: updated));
    return true;
  }
}

class _FakeMealPlanRecordCubit extends MealPlanRecordCubit {
  _FakeMealPlanRecordCubit()
    : super(mealPlanRecordRepository: MealPlanRecordRepository.create());

  @override
  Future<bool> startMealPlan({
    required int mealPlanId,
    int? version,
    DateTime? startDate,
  }) async => true;
}

void main() {
  const testPlan = MealPlanDto(
    id: 10,
    name: 'Cutting Plan',
    description: 'High protein cut',
    version: 1,
    totalWeeks: 4,
    totalDays: 28,
    totalMeals: 84,
    isFavorite: false,
    createdBy: CreatedBy.user,
  );

  testWidgets(
    'MealPlanListScreen renders SearchFavoriteForm and searches with favorite filter',
    (tester) async {
      final cubit = _FakeMealPlanCubit([testPlan]);
      addTearDown(cubit.close);

      final recordCubit = _FakeMealPlanRecordCubit();
      addTearDown(recordCubit.close);

      final router = GoRouter(
        initialLocation: Routes.mealPlanList.name,
        routes: [
          GoRoute(
            path: Routes.mealPlanList.name,
            builder: (_, _) => const MealPlanListScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<MealPlanCubit>.value(value: cubit),
            BlocProvider<MealPlanRecordCubit>.value(value: recordCubit),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SearchFavoriteForm), findsOneWidget);
      expect(find.text('Cutting Plan'), findsOneWidget);

      // Toggle favorite filter in SearchFavoriteForm
      await tester.tap(find.byType(HeartCheckbox));
      await tester.pumpAndSettle();

      // Submit search
      await tester.tap(find.byType(SearchFormButton));
      await tester.pumpAndSettle();

      expect(cubit.lastIsFavorite, isTrue);
    },
  );

  testWidgets('MealPlanListScreen allows toggling favorite on meal plan item', (
    tester,
  ) async {
    final cubit = _FakeMealPlanCubit([testPlan]);
    addTearDown(cubit.close);

    final recordCubit = _FakeMealPlanRecordCubit();
    addTearDown(recordCubit.close);

    final router = GoRouter(
      initialLocation: Routes.mealPlanList.name,
      routes: [
        GoRoute(
          path: Routes.mealPlanList.name,
          builder: (_, _) => const MealPlanListScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MealPlanCubit>.value(value: cubit),
          BlocProvider<MealPlanRecordCubit>.value(value: recordCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final itemHeart = find.descendant(
      of: find.byKey(const ValueKey('meal-plan-card-10')),
      matching: find.byIcon(Icons.favorite_border),
    );
    expect(itemHeart, findsOneWidget);

    await tester.tap(itemHeart);
    await tester.pumpAndSettle();

    expect(cubit.toggledId, 10);
    expect(cubit.state.mealPlans.first.isFavorite, isTrue);
  });
}
