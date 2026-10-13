import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/services/inputs/food_input.dart';
import 'package:myfitnesstale/src/widgets/foods/food_form_widget.dart';
import 'package:myfitnesstale/src/cubits/states/macro_tracking_state.dart';
import 'package:myfitnesstale/src/services/dtos/macro_tracking_dto.dart';
import 'package:myfitnesstale/src/widgets/macro_goals/macro_goals_content_widget.dart';
import 'package:myfitnesstale/src/services/dtos/food_dto.dart';
import 'package:myfitnesstale/src/services/dtos/recipe_dto.dart';
import 'package:myfitnesstale/src/services/dtos/meal_plan_dto.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/utilities/sizes/screen_size.dart';
import 'package:myfitnesstale/src/widgets/foods/food_details_widget.dart';
import 'package:myfitnesstale/src/widgets/recipes/recipe_details_widget.dart';
import 'package:myfitnesstale/src/widgets/meal_plans/meal_plan_schedule_widget.dart';

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

  Future<void> pumpNarrow(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(320, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(2)),
        child: child!,
      ),
      home: Scaffold(
          body: SingleChildScrollView(
              child: Padding(
        padding: const EdgeInsets.all(16),
        child: widget,
      ))),
    ));
    expect(tester.takeException(), isNull);
  }

  testWidgets('food nutrition fits at 320px and 200% text', (tester) async {
    await pumpNarrow(
        tester,
        FoodDetailsWidget(
          sizes: sizes,
          onToggleFavorite: () {},
          food: const FoodDto(
              id: 1,
              name: 'Fortified rolled oats',
              category: FoodCategory.grainsAndCereals,
              servingSizeBaseGrams: 50,
              caloriesBase: 200,
              proteinBase: 5,
              carbsBase: 30,
              fatBase: 4,
              sodiumBase: 10,
              isFavorite: true,
              createdBy: CreatedBy.user),
        ));
    expect(find.text('Sodium: 10mg'), findsOneWidget);
    expect(
        find.text('No portions defined. Serving size: 50g.'), findsOneWidget);
  });

  testWidgets('food editor submits a full input and preserves hidden values',
      (tester) async {
    FoodInput? submitted;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: FoodFormWidget(
      theme: ThemeData(),
      sizes: sizes,
      initialFood: const FoodDto(
          id: 1,
          name: 'Oats',
          brand: 'Mill',
          barcode: '123',
          category: FoodCategory.grainsAndCereals,
          servingSizeBaseGrams: 50,
          caloriesBase: 200,
          proteinBase: 5,
          carbsBase: 30,
          fatBase: 4,
          sodiumBase: 10,
          micros: Micronutrients(potassiumMg: 100),
          isFavorite: true,
          createdBy: CreatedBy.user),
      onSubmit: (input) => submitted = input,
    ))));
    final button = find.byKey(const ValueKey('food-form-save-btn'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    expect(submitted, isNotNull);
    expect(submitted!.barcode.value, '123');
    expect(submitted!.micros.value?.potassiumMg, 100);
    expect(submitted!.isFavorite, isTrue);
    expect(submitted!.sodiumBase.value, 10);
    expect(submitted!.servingSizeBaseGrams, 50);
  });

  testWidgets('recipe nutrition fits at 320px and 200% text', (tester) async {
    await pumpNarrow(
        tester,
        RecipeDetailsWidget(
          sizes: sizes,
          recipe: const RecipeDto(
              id: 1,
              name: 'Porridge',
              servingsYield: 2,
              servingCalories: 200,
              servingProtein: 5,
              servingCarbs: 30,
              servingFat: 4,
              createdBy: CreatedBy.user),
        ));
    expect(find.text('Nutrition Per Serving'), findsOneWidget);
  });

  testWidgets('active macro goal fits at 320px and 200% text', (tester) async {
    await pumpNarrow(
        tester,
        MacroGoalsContentWidget(
          sizes: sizes,
          theme: ThemeData(),
          state: MacroTrackingState(
              selectedDate: DateTime(2026, 10, 13),
              isLoading: false,
              activeGoal: const MacroGoalDto(
                id: 1,
                name: 'Daily target',
                targetCalories: 2000,
                targetProtein: 100,
                targetCarbs: 200,
                targetFat: 60,
                targetWaterIntakeMl: 2500,
                isActive: true,
                phase: WeightGoalPhase.maintain,
              )),
        ));
    expect(find.text('Active Macro Target'), findsOneWidget);
  });

  testWidgets('populated meal schedule fits at 320px and 200% text',
      (tester) async {
    await pumpNarrow(
        tester,
        MealPlanScheduleWidget(
          theme: ThemeData(),
          sizes: sizes,
          plan: const MealPlanDto(
            id: 1,
            name: 'Plan',
            version: 1,
            totalWeeks: 1,
            totalDays: 1,
            totalMeals: 1,
            isFavorite: false,
            createdBy: CreatedBy.user,
            weeks: [
              MealPlanWeekDto(
                id: 1,
                mealPlanId: 1,
                planVersion: 1,
                weekNumber: 1,
                phase: MealPlanPhase.maintain,
                targetCalories: 200,
                targetProtein: 5,
                targetCarbs: 30,
                targetFat: 4,
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
                    targetCalories: 200,
                    targetProtein: 5,
                    targetCarbs: 30,
                    targetFat: 4,
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
                          totalCalories: 200,
                          totalProtein: 5,
                          totalCarbs: 30,
                          totalFat: 4,
                          name: 'Fortified rolled oats breakfast',
                          createdBy: CreatedBy.user)
                    ],
                  )
                ],
              )
            ],
          ),
        ));
    expect(find.text('Fortified rolled oats breakfast (breakfast)'),
        findsOneWidget);
  });
}
