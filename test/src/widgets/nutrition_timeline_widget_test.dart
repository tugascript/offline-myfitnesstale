import 'package:myfitnesstale/src/services/inputs/quick_food_log_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/cubits/food_cubit.dart';
import 'package:myfitnesstale/src/cubits/macro_tracking_cubit.dart';
import 'package:myfitnesstale/src/cubits/recipe_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/food_dto.dart';
import 'package:myfitnesstale/src/services/dtos/macro_tracking_dto.dart';
import 'package:myfitnesstale/src/services/dtos/recipe_dto.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/utilities/sizes/screen_size.dart';
import 'package:myfitnesstale/src/widgets/macros/log_food_modal.dart';
import 'package:myfitnesstale/src/widgets/macros/nutrition_hour_row.dart';
import 'package:myfitnesstale/src/widgets/macros/nutrition_timeline_widget.dart';

class _Foods extends FoodCubit {
  _Foods() {
    emit(
      state.copyWith(
        foods: const [
          FoodDto(
            id: 1,
            name: 'Oats',
            category: FoodCategory.grainsAndCereals,
            servingSizeBaseGrams: 100,
            caloriesBase: 100,
            proteinBase: 10,
            carbsBase: 20,
            fatBase: 2,
            isFavorite: false,
            createdBy: CreatedBy.user,
          ),
        ],
      ),
    );
  }
}

class _Recipes extends RecipeCubit {
  _Recipes() {
    emit(
      state.copyWith(
        recipes: const [
          RecipeDto(
            id: 2,
            name: 'Porridge',
            servingsYield: 1,
            servingCalories: 100,
            servingProtein: 10,
            servingCarbs: 20,
            servingFat: 2,
            createdBy: CreatedBy.user,
          ),
        ],
      ),
    );
  }
}

class _Macros extends MacroTrackingCubit {
  QuickFoodLogInput? quickInput;
  bool quickSuccess = false;
  int quickSaves = 0;

  @override
  Future<bool> logQuickFood(
    QuickFoodLogInput input, {
    DateTime? logTime,
    MealType mealType = MealType.snack,
  }) async {
    quickInput = input;
    loggedTime = logTime;
    quickSaves++;
    return quickSuccess;
  }

  DateTime? loggedTime;
  int? loggedFoodId;
  int? loggedRecipeId;

  @override
  Future<bool> logFoodItem({
    DateTime? logTime,
    required MealType mealType,
    required int foodId,
    int? portionId,
    required int amount,
  }) async {
    loggedTime = logTime;
    loggedFoodId = foodId;
    return false;
  }

  @override
  Future<bool> logRecipe({
    DateTime? logTime,
    required MealType mealType,
    required int recipeId,
    int servings = 1,
  }) async {
    loggedTime = logTime;
    loggedRecipeId = recipeId;
    return false;
  }
}

MealLogDto _meal(int id, DateTime time) => MealLogDto(
  id: id,
  dailyLogId: 1,
  mealType: MealType.snack,
  logTime: time,
  totalCalories: 100,
  totalProtein: 10,
  totalCarbs: 20,
  totalFat: 2,
  items: [
    MealLogItemDto(
      id: id,
      mealLogId: id,
      foodId: 1,
      amount: 100,
      loggedFoodName: 'Food $id with a longer name',
      loggedCalories: 100,
      loggedProtein: 10,
      loggedCarbs: 20,
      loggedFat: 2,
    ),
  ],
);

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);

  for (final scale in [1.0, 2.0]) {
    testWidgets('timeline orders local hours and fits 320px at scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      int? addedHour;
      int? deletedItem;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: NutritionTimelineWidget(
                  meals: [
                    _meal(3, DateTime(2025, 1, 10, 8, 45).toUtc()),
                    _meal(1, DateTime(2025, 1, 10)),
                    _meal(2, DateTime(2025, 1, 10, 8, 5)),
                    _meal(4, DateTime(2025, 1, 10, 23, 59)),
                  ],
                  selectedDate: DateTime(2025, 1, 10),
                  theme: ThemeData(),
                  sizes: sizes,
                  onAdd: (hour) => addedHour = hour,
                  onDelete: (item) => deletedItem = item.id,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(NutritionHourRow), findsNWidgets(24));
      expect(find.text('Breakfast'), findsNothing);
      final eight = tester.widget<NutritionHourRow>(
        find.byKey(const ValueKey('nutrition-hour-8')),
      );
      expect(eight.meals.map((m) => m.id), [2, 3]);
      expect(find.text('200 kcal'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('nutrition-add-0')));
      expect(addedHour, 0);
      final delete = find.byTooltip('Delete Food 2 with a longer name');
      await tester.ensureVisible(delete);
      await tester.tap(delete);
      expect(deletedItem, 2);
      final last = find.byKey(const ValueKey('nutrition-add-23'));
      await tester.ensureVisible(last);
      await tester.tap(last);
      expect(addedHour, 23);
      expect(tester.takeException(), isNull);
    });
  }

  for (final recipe in [false, true]) {
    testWidgets(
      '${recipe ? 'recipe' : 'food'} logging keeps date and chosen time',
      (tester) async {
        final macros = _Macros();
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<FoodCubit>(create: (_) => _Foods()),
              BlocProvider<RecipeCubit>(create: (_) => _Recipes()),
              BlocProvider<MacroTrackingCubit>.value(value: macros),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: LogFoodModal(
                  theme: ThemeData(),
                  sizes: sizes,
                  selectedDate: DateTime(2025, 1, 10),
                  initialTime: const TimeOfDay(hour: 0, minute: 0),
                ),
              ),
            ),
          ),
        );
        addTearDown(macros.close);
        expect(find.byType(DropdownButtonFormField<MealType>), findsNothing);
        expect(find.text('00:00'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('log-food-time-btn')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TimePickerDialog>(find.byType(TimePickerDialog))
              .initialTime,
          const TimeOfDay(hour: 0, minute: 0),
        );
        await tester.tap(find.byTooltip('Switch to text input mode'));
        await tester.pumpAndSettle();
        final fields = find.descendant(
          of: find.byType(TimePickerDialog),
          matching: find.byType(TextField),
        );
        await tester.enterText(fields.at(0), '9');
        await tester.enterText(fields.at(1), '15');
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        if (recipe) {
          await tester.tap(find.text('Recipe'));
          await tester.pumpAndSettle();
        }
        final prefix = recipe ? 'log-recipe' : 'log-food';
        await tester.tap(find.byKey(ValueKey('$prefix-select-dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(recipe ? 'Porridge (100 kcal/serv)' : 'Oats').last,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('$prefix-confirm-btn')));
        await tester.pumpAndSettle();
        expect(macros.loggedTime, DateTime(2025, 1, 10, 9, 15));
        expect(
          recipe ? macros.loggedRecipeId : macros.loggedFoodId,
          recipe ? 2 : 1,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'Quick Add logs totals at the chosen time at text scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final macros = _Macros();
        addTearDown(macros.close);
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<FoodCubit>(create: (_) => _Foods()),
              BlocProvider<RecipeCubit>(create: (_) => _Recipes()),
              BlocProvider<MacroTrackingCubit>.value(value: macros),
            ],
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => LogFoodModal(
                        theme: ThemeData(),
                        sizes: sizes,
                        selectedDate: DateTime(2025, 1, 10),
                        initialTime: const TimeOfDay(hour: 23, minute: 0),
                      ),
                    ),
                    child: const Text('Open Log'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open Log'));
        await tester.pumpAndSettle();
        Future<void> tap(Finder finder) async {
          await tester.ensureVisible(finder);
          await tester.tap(finder);
          await tester.pumpAndSettle();
        }

        Future<void> enter(String field, String value) async {
          final finder = find.byKey(ValueKey('quick-add-$field-input'));
          await tester.ensureVisible(finder);
          await tester.enterText(finder, value);
          await tester.pumpAndSettle();
        }

        await tap(find.text('Quick Add'));
        final submit = find.byKey(const ValueKey('quick-add-confirm-btn'));
        await tap(submit);
        expect(macros.quickSaves, 0);
        await enter('name', '  Cafe lunch  ');
        await enter('protein', '-1');
        await tap(submit);
        expect(macros.quickSaves, 0);
        await enter('protein', '30');
        await enter('carbs', '60');
        await enter('fat', '15');
        final calories = find.byKey(const ValueKey('quick-add-calories-input'));
        expect(
          tester
              .widget<TextFormField>(
                find.descendant(
                  of: calories,
                  matching: find.byType(TextFormField),
                ),
              )
              .controller!
              .text,
          '495',
        );
        // The draft survives switching to the library and back.
        await tap(find.text('Food'));
        await tap(find.text('Quick Add'));
        await tap(submit);
        expect(macros.quickSaves, 1);
        expect(macros.quickInput?.name, 'Cafe lunch');
        expect(macros.quickInput?.calories, 495);
        expect(macros.quickInput?.protein, 30);
        expect(macros.quickInput?.carbs, 60);
        expect(macros.quickInput?.fat, 15);
        expect(macros.loggedTime, DateTime(2025, 1, 10, 23));
        expect(
          find.text('Could not save this entry. Please try again.'),
          findsOneWidget,
        );
        // Manual calories are submitted unchanged, and success closes the dialog.
        await tap(find.byKey(const ValueKey('quick-add-calculate-calories')));
        await enter('calories', '525');
        macros.quickSuccess = true;
        await tap(submit);
        expect(macros.quickSaves, 2);
        expect(macros.quickInput?.calories, 525);
        expect(find.byType(LogFoodModal), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
