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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/data/repositories/foods/inputs/food_input.dart';
import 'package:myfitnesstale/src/ui/foods/widgets/food_form_widget.dart';
import 'package:myfitnesstale/src/data/repositories/macros/dtos/macro_tracking_dto.dart';
import 'package:myfitnesstale/src/ui/macros/widgets/goals/active_macro_goal.dart';
import 'package:myfitnesstale/src/data/repositories/foods/dtos/food_dto.dart';
import 'package:myfitnesstale/src/data/repositories/recipes/dtos/recipe_dto.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/ui/foods/widgets/food_details_widget.dart';
import 'package:myfitnesstale/src/ui/recipes/widgets/recipe_details_widget.dart';

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

  Future<void> pumpNarrow(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(320, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(16), child: widget),
          ),
        ),
      ),
    );
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
          createdBy: CreatedBy.user,
        ),
      ),
    );
    expect(find.text('Sodium: 10mg'), findsOneWidget);
    expect(
      find.text('No portions defined. Serving size: 50g.'),
      findsOneWidget,
    );
  });

  testWidgets('food editor submits a full input and preserves hidden values', (
    tester,
  ) async {
    FoodInput? submitted;
    await tester.pumpWidget(
      MaterialApp(
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
              createdBy: CreatedBy.user,
            ),
            onSubmit: (input) => submitted = input,
          ),
        ),
      ),
    );
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
          createdBy: CreatedBy.user,
        ),
      ),
    );
    expect(find.text('Nutrition Per Serving'), findsOneWidget);
  });

  testWidgets('active macro goal fits at 320px and 200% text', (tester) async {
    await pumpNarrow(
      tester,
      ActiveMacroGoal(
        sizes: sizes,
        theme: ThemeData(),
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
        ),
      ),
    );
    expect(find.text('Active Macro Target'), findsOneWidget);
  });

  testWidgets('active calorie cycling goal fits at 320px and 200% text', (
    tester,
  ) async {
    await pumpNarrow(
      tester,
      ActiveMacroGoal(
        sizes: sizes,
        theme: ThemeData(),
        activeGoal: const MacroGoalDto(
          id: 2,
          name: 'Weekend Refeed',
          targetCalories: 2000,
          targetProtein: 160,
          targetCarbs: 193,
          targetFat: 63,
          targetWaterIntakeMl: 2500,
          totalTargetCalories: 14000,
          goalType: MacroGoalType.calorieCycling,
          days: [
            DayMacroGoalDto(
              id: 1,
              weekMacroGoalId: 2,
              days: [
                DayOfWeek.monday,
                DayOfWeek.tuesday,
                DayOfWeek.wednesday,
                DayOfWeek.thursday,
                DayOfWeek.friday,
              ],
              name: 'Weekdays',
              targetCalories: 1800,
              targetProtein: 160,
              targetCarbs: 150,
              targetFat: 60,
            ),
            DayMacroGoalDto(
              id: 2,
              weekMacroGoalId: 2,
              days: [DayOfWeek.saturday, DayOfWeek.sunday],
              name: 'Weekend Cheat',
              targetCalories: 2500,
              targetProtein: 160,
              targetCarbs: 300,
              targetFat: 70,
            ),
          ],
          isActive: true,
          phase: WeightGoalPhase.cut,
        ),
      ),
    );
    expect(find.textContaining('Calorie Cycling'), findsOneWidget);
    expect(find.text('Mon, Tue, Wed, Thu, Fri'), findsOneWidget);
    expect(find.text('Sat, Sun'), findsOneWidget);
  });

  testWidgets(
    'loading active macro goal skeleton fits at 320px and 200% text',
    (tester) async {
      await pumpNarrow(
        tester,
        ActiveMacroGoal(
          sizes: sizes,
          theme: ThemeData(),
          activeGoal: null,
          isLoading: true,
          hasLoaded: false,
        ),
      );
      expect(find.text('No active macro goal'), findsNothing);
      expect(find.text('Active Macro Target'), findsOneWidget);

      await pumpNarrow(
        tester,
        ActiveMacroGoal(
          sizes: sizes,
          theme: ThemeData(),
          activeGoal: null,
          isLoading: false,
          hasLoaded: false,
        ),
      );
      expect(find.text('No active macro goal'), findsNothing);
      expect(find.text('Active Macro Target'), findsOneWidget);

      await pumpNarrow(
        tester,
        ActiveMacroGoal(
          sizes: sizes,
          theme: ThemeData(),
          activeGoal: null,
          isLoading: false,
          hasLoaded: true,
        ),
      );
      expect(find.text('No active macro goal'), findsOneWidget);

      var retried = false;
      await pumpNarrow(
        tester,
        ActiveMacroGoal(
          sizes: sizes,
          theme: ThemeData(),
          activeGoal: null,
          isLoading: false,
          hasLoaded: false,
          hasError: true,
          onRetry: () => retried = true,
        ),
      );
      expect(find.text('No active macro goal'), findsNothing);
      expect(find.text('Could not load active macro goal'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('macro-goal-retry-button')));
      await tester.pump();
      expect(retried, isTrue);
    },
  );
}
