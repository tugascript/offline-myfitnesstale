// Copyright (C) 2026 afonsobarracha
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

import 'package:myfitnesstale/src/utils/nullable.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_cubit.dart';
import 'package:myfitnesstale/src/ui/exercises/view_models/exercise_record_cubit.dart';
import 'package:myfitnesstale/src/ui/foods/view_models/food_cubit.dart';
import 'package:myfitnesstale/src/ui/macros/view_models/macro_tracking_cubit.dart';
import 'package:myfitnesstale/src/ui/meal_plans/view_models/meal_plan_cubit.dart';
import 'package:myfitnesstale/src/ui/meal_plans/view_models/meal_plan_record_cubit.dart';
import 'package:myfitnesstale/src/ui/home/view_models/profile_cubit.dart';
import 'package:myfitnesstale/src/ui/recipes/view_models/recipe_cubit.dart';
import 'package:myfitnesstale/src/ui/workout_plans/view_models/workout_plan_record_cubit.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/models/sqlite/exercise_model.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/exercise_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/exercise_repository.dart';
import 'package:myfitnesstale/src/data/repositories/foods/dtos/food_dto.dart';
import 'package:myfitnesstale/src/data/repositories/macros/dtos/macro_tracking_dto.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/dtos/meal_plan_dto.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/dtos/meal_plan_record_dto.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/dtos/recipe_dto.dart';
import 'package:myfitnesstale/src/data/repositories/exercises/dtos/strength_goal_dto.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/exercises/screens/strength_goals_screen.dart';
import 'package:myfitnesstale/src/ui/foods/screens/food_creation_screen.dart';
import 'package:myfitnesstale/src/ui/foods/screens/food_details_screen.dart';
import 'package:myfitnesstale/src/ui/foods/screens/food_update_screen.dart';
import 'package:myfitnesstale/src/ui/foods/screens/foods_screen.dart';
import 'package:myfitnesstale/src/ui/macros/screens/macro_goals_screen.dart';
import 'package:myfitnesstale/src/ui/macros/screens/macro_tracker_screen.dart';
import 'package:myfitnesstale/src/ui/meal_plans/screens/meal_plan_creation_screen.dart';
import 'package:myfitnesstale/src/ui/meal_plans/screens/meal_plan_details_screen.dart';
import 'package:myfitnesstale/src/ui/meal_plans/screens/meal_plan_list_screen.dart';
import 'package:myfitnesstale/src/ui/meal_plans/screens/meal_plan_update_screen.dart';
import 'package:myfitnesstale/src/ui/recipes/screens/recipe_creation_screen.dart';
import 'package:myfitnesstale/src/ui/recipes/screens/recipe_details_screen.dart';
import 'package:myfitnesstale/src/ui/recipes/screens/recipe_update_screen.dart';
import 'package:myfitnesstale/src/ui/recipes/screens/recipes_screen.dart';
import 'package:myfitnesstale/src/ui/home/widgets/active/active_plans_carousel.dart';
import 'package:myfitnesstale/src/ui/home/widgets/quick_actions_widget.dart';
import 'package:myfitnesstale/src/ui/exercises/widgets/strength_goal/strength_goal_form_modal.dart';
import 'package:myfitnesstale/src/ui/foods/widgets/food_form_widget.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/goals/macro_goal_form_modal.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/log_food_modal.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/macro_tracker_day_widget.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/macro_tracker_month_widget.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/macro_tracker_week_widget.dart';
import 'package:myfitnesstale/src/ui/meal_plans/widgets/meal_plan_form_widget.dart';
import 'package:myfitnesstale/src/ui/recipes/widgets/recipe_form_widget.dart';
import 'package:myfitnesstale/src/data/repositories/foods/food_repository.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/recipe_repository.dart';
import 'package:myfitnesstale/src/data/repositories/macros/macro_tracking_repository.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/meal_plans/meal_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_repository.dart';
import 'package:myfitnesstale/src/data/repositories/workout_plans/workout_plan_record_repository.dart';
import 'package:myfitnesstale/src/data/repositories/profile/profile_repository.dart';

const _food = FoodDto(
  id: 1,
  name: 'Fortified rolled oats with a long brand name',
  category: FoodCategory.grainsAndCereals,
  servingSizeBaseGrams: 100,
  caloriesBase: 380,
  proteinBase: 10,
  carbsBase: 60,
  fatBase: 8,
  isFavorite: true,
  createdBy: CreatedBy.user,
  portions: [
    FoodPortionDto(
      id: 1,
      foodId: 1,
      portionName: 'One large measuring cup of rolled oats',
      gramWeight: 100,
    ),
  ],
);
const _recipe = RecipeDto(
  id: 1,
  name: 'Breakfast porridge with a long recipe name',
  servingsYield: 2,
  servingCalories: 190,
  servingProtein: 5,
  servingCarbs: 30,
  servingFat: 4,
  createdBy: CreatedBy.user,
  items: [
    RecipeItemDto(
      id: 1,
      recipeId: 1,
      foodId: 1,
      portionId: 1,
      amount: 1,
      totalCalories: 380,
      totalProtein: 10,
      totalCarbs: 60,
      totalFat: 8,
      foodName: 'Fortified rolled oats with a long brand name',
      portionName: 'One large measuring cup of rolled oats',
    ),
  ],
);
const _plan = MealPlanDto(
  id: 1,
  name: 'A long personalized weekly meal plan name',
  version: 1,
  totalWeeks: 1,
  totalDays: 1,
  totalMeals: 1,
  isFavorite: true,
  createdBy: CreatedBy.user,
  weeks: [
    MealPlanWeekDto(
      id: 1,
      mealPlanId: 1,
      planVersion: 1,
      weekNumber: 1,
      phase: MealPlanPhase.maintain,
      targetCalories: 380,
      targetProtein: 10,
      targetCarbs: 60,
      targetFat: 8,
      totalDays: 1,
      totalMeals: 1,
      createdBy: CreatedBy.user,
      days: [
        MealPlanDayDto(
          id: 1,
          mealPlanId: 1,
          mealPlanWeekId: 1,
          planVersion: 1,
          day: 1,
          name: 'A long breakfast planning day name',
          targetCalories: 380,
          targetProtein: 10,
          targetCarbs: 60,
          targetFat: 8,
          totalMeals: 1,
          createdBy: CreatedBy.user,
          meals: [
            MealPlanMealDto(
              id: 1,
              position: 1,
              mealPlanId: 1,
              mealPlanWeekId: 1,
              mealPlanDayId: 1,
              planVersion: 1,
              mealType: MealType.breakfast,
              name: 'A long breakfast meal name',
              totalCalories: 380,
              totalProtein: 10,
              totalCarbs: 60,
              totalFat: 8,
              createdBy: CreatedBy.user,
              items: [
                MealPlanMealItemDto(
                  id: 1,
                  mealPlanMealId: 1,
                  foodId: 1,
                  portionId: 1,
                  amount: 1,
                  totalCalories: 380,
                  totalProtein: 10,
                  totalCarbs: 60,
                  totalFat: 8,
                  foodName: 'Fortified rolled oats',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
const _macroGoal = MacroGoalDto(
  id: 1,
  name: 'Daily macro targets',
  targetCalories: 2000,
  targetProtein: 150,
  targetCarbs: 200,
  targetFat: 65,
  targetWaterIntakeMl: 2500,
  isActive: true,
  phase: WeightGoalPhase.maintain,
);
final _date = DateTime(2026, 10, 13);
final _strengthGoal = StrengthGoalDto(
  id: 1,
  name: 'A long bench press strength goal',
  targetReps: 12,
  targetWeight: 100000,
  targetMaxStrength: 120000,
  exerciseId: 1,
  status: ProgressStatus.inProgress,
  startDate: _date,
);

class _Foods extends FoodCubit {
  _Foods() : super(foodRepository: FoodRepository.create()) {
    emit(state.copyWith(foods: [_food], selectedFood: const Nullable(_food)));
  }

  @override
  Future<void> getFood(int id) async {}

  @override
  Future<void> getFoods({
    String? search,
    FoodCategory? category,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {}
}

class _Recipes extends RecipeCubit {
  _Recipes() : super(recipeRepository: RecipeRepository.create()) {
    emit(
      state.copyWith(
        recipes: [_recipe],
        selectedRecipe: const Nullable(_recipe),
      ),
    );
  }

  @override
  Future<void> getRecipe(int id) async {}

  @override
  Future<void> getRecipes({
    String? search,
    bool isFavorite = false,
    int limit = 20,
    int offset = 0,
  }) async {}
}

class _Exercises extends ExerciseCubit {
  _Exercises() : super(exerciseRepository: ExerciseRepository.create()) {
    emit(
      state.copyWith(
        exercises: [
          ExerciseDto.fromModel(
            Exercise.create(
              name: 'Bench press with a long exercise name',
              muscleGroup: MuscleGroup.push,
              muscles: const TargetMuscles(primary: {}, secondary: {}),
            ).copyWith(id: const Nullable(1)),
          ),
        ],
      ),
    );
  }
}

class _Goals extends ExerciseRecordCubit {
  _Goals()
    : super(exerciseRecordRepository: ExerciseRecordRepository.create()) {
    emit(
      state.copyWith(
        activeStrengthGoal: Nullable(_strengthGoal),
        strengthGoals: [
          _strengthGoal.copyWith(id: 2, status: ProgressStatus.completed),
        ],
      ),
    );
  }

  @override
  Future<void> getActiveStrengthGoal({int? exerciseId}) async {}

  @override
  Future<void> getStrengthGoals({
    int? exerciseId,
    bool skipInProgress = false,
    int limit = 20,
    int offset = 0,
  }) async {}
}

class _Macros extends MacroTrackingCubit {
  _Macros() : super(macroTrackingRepository: MacroTrackingRepository.create()) {
    emit(
      state.copyWith(
        activeGoal: const Nullable(_macroGoal),
        selectedDailyLog: Nullable(
          DailyNutritionLogDto(
            id: 1,
            date: 20261013,
            waterIntakeMl: 1500,
            totalCalories: 380,
            totalProtein: 10,
            totalCarbs: 60,
            totalFat: 8,
            totalFiber: 0,
            meals: [
              MealLogDto(
                id: 1,
                dailyLogId: 1,
                mealType: MealType.breakfast,
                logTime: _date,
                totalCalories: 380,
                totalProtein: 10,
                totalCarbs: 60,
                totalFat: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<void> getActiveMacroGoal() async {}

  @override
  Future<void> getMacroGoals({int limit = 20, int offset = 0}) async {}

  @override
  Future<void> getDailyLog(DateTime date) async {}

  @override
  Future<void> getDailyLogsForRange({
    required DateTime start,
    required DateTime end,
  }) async {}
}

class _Plans extends MealPlanCubit {
  _Plans() : super(mealPlanRepository: MealPlanRepository.create()) {
    emit(
      state.copyWith(
        mealPlans: [_plan],
        selectedMealPlan: const Nullable(_plan),
      ),
    );
  }

  @override
  Future<void> getMealPlan(int id, {int? version}) async {}

  @override
  Future<void> getMealPlans({
    String? search,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
  }) async {}
}

class _Records extends MealPlanRecordCubit {
  _Records()
    : super(mealPlanRecordRepository: MealPlanRecordRepository.create()) {
    emit(
      state.copyWith(
        activeRecord: Nullable(
          MealPlanRecordDto(
            id: 1,
            mealPlanId: 1,
            mealPlanVersion: 1,
            status: ProgressStatus.inProgress,
            startedAt: _date,
            currentWeek: 1,
            currentDay: 1,
            planName: _plan.name,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> getActiveMealPlanRecord() async {}
}

typedef _Content = Widget Function(DataDisplaySizesList sizes, ThemeData theme);

void main() {
  final contents = <String, _Content>{
    'foods screen': (_, _) => const FoodsScreen(),
    'food creation screen': (_, _) => const FoodCreationScreen(),
    'food update screen': (_, _) => const FoodUpdateScreen(foodId: 1),
    'food details screen': (_, _) => const FoodDetailsScreen(foodId: 1),
    'recipes screen': (_, _) => const RecipesScreen(),
    'recipe creation screen': (_, _) => const RecipeCreationScreen(),
    'recipe update screen': (_, _) => const RecipeUpdateScreen(recipeId: 1),
    'recipe details screen': (_, _) => const RecipeDetailsScreen(recipeId: 1),
    'meal-plans screen': (_, _) => const MealPlanListScreen(),
    'meal-plan creation screen': (_, _) => const MealPlanCreationScreen(),
    'meal-plan update screen': (_, _) =>
        const MealPlanUpdateScreen(mealPlanId: 1),
    'meal-plan details screen': (_, _) =>
        const MealPlanDetailsScreen(mealPlanId: 1),
    'macro-goals screen': (_, _) => const MacroGoalsScreen(),
    'macro-tracker screen': (_, _) => const MacroTrackerScreen(),
    'food editor': (sizes, theme) => SingleChildScrollView(
      child: FoodFormWidget(
        sizes: sizes,
        theme: theme,
        initialFood: _food,
        onSubmit: (_) {},
      ),
    ),
    'recipe editor': (sizes, theme) => RecipeFormWidget(
      sizes: sizes,
      theme: theme,
      initialRecipe: _recipe,
      onSubmit: (_) {},
    ),
    'meal-plan editor': (sizes, theme) => MealPlanFormWidget(
      sizes: sizes,
      theme: theme,
      initialPlan: _plan,
      onSubmit: (_) {},
    ),
    'macro-goal dialog': (sizes, theme) => MacroGoalFormModal(
      sizes: sizes,
      theme: theme,
      existingGoal: _macroGoal,
    ),
    'strength-goal dialog': (sizes, theme) => StrengthGoalFormModal(
      sizes: sizes,
      theme: theme,
      existingGoal: _strengthGoal,
    ),
    'meal-log dialog': (sizes, theme) =>
        LogFoodModal(sizes: sizes, theme: theme, selectedDate: _date),
    'day tracker': (sizes, theme) =>
        MacroTrackerDayWidget(theme: theme, sizes: sizes, selectedDate: _date),
    'week tracker': (sizes, theme) => MacroTrackerWeekWidget(
      theme: theme,
      sizes: sizes,
      selectedDate: _date,
      onSelectDate: (_) {},
    ),
    'month tracker': (sizes, theme) => MacroTrackerMonthWidget(
      theme: theme,
      sizes: sizes,
      selectedDate: _date,
      onSelectDate: (_) {},
    ),
    'dashboard': (sizes, theme) => SingleChildScrollView(
      child: Column(
        children: [
          ActivePlansCarousel(theme: theme, sizes: sizes),
          QuickActionsWidget(theme: theme, sizes: sizes),
        ],
      ),
    ),
    'populated strength screen': (sizes, theme) => const StrengthGoalsScreen(),
  };
  for (final entry in contents.entries) {
    for (final width in [320.0, 600.0, 1200.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('${entry.key} fits width $width and text $scale', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<FoodCubit>(create: (_) => _Foods()),
                BlocProvider<RecipeCubit>(create: (_) => _Recipes()),
                BlocProvider<ExerciseCubit>(create: (_) => _Exercises()),
                BlocProvider<ExerciseRecordCubit>(create: (_) => _Goals()),
                BlocProvider<ProfileCubit>(
                  create: (_) => ProfileCubit(
                    profileRepository: ProfileRepository.create(),
                  ),
                ),
                BlocProvider<WorkoutPlanRecordCubit>(
                  create: (_) => WorkoutPlanRecordCubit(
                    workoutPlanRecordRepository:
                        WorkoutPlanRecordRepository.create(),
                    workoutPlanRepository: WorkoutPlanRepository.create(),
                  ),
                ),
                BlocProvider<MacroTrackingCubit>(create: (_) => _Macros()),
                BlocProvider<MealPlanCubit>(create: (_) => _Plans()),
                BlocProvider<MealPlanRecordCubit>(create: (_) => _Records()),
              ],
              child: MaterialApp.router(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                routerConfig: GoRouter(
                  routes: [
                    GoRoute(
                      path: '/',
                      builder: (context, state) {
                        final sizes = DataDisplaySizes.getDataDisplaySizes(
                          BreakPoint.fromContext(context).screenSize,
                        );
                        return Scaffold(
                          body: entry.value(sizes, Theme.of(context)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (entry.key == 'meal-log dialog') {
            final foodSelector = find.byKey(
              const ValueKey('log-food-select-dropdown'),
            );
            await tester.ensureVisible(foodSelector);
            await tester.tap(foodSelector);
            await tester.pumpAndSettle();
            await tester.tap(find.text(_food.name).last);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.ensureVisible(find.text('Recipe').last);
            await tester.pumpAndSettle();
            await tester.tap(find.text('Recipe').last);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            tester.view.viewInsets = const FakeViewPadding(bottom: 280);
            addTearDown(tester.view.resetViewInsets);
            await tester.pumpAndSettle();
            final confirm = find.byKey(
              const ValueKey('log-recipe-confirm-btn'),
            );
            await tester.ensureVisible(confirm);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(confirm.hitTestable(), findsOneWidget);
            await tester.ensureVisible(find.text('Quick Add'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Quick Add'));
            await tester.pumpAndSettle();
            final quickConfirm = find.byKey(
              const ValueKey('quick-add-confirm-btn'),
            );
            await tester.ensureVisible(quickConfirm);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(quickConfirm.hitTestable(), findsOneWidget);
          }
        });
      }
    }
  }
}
