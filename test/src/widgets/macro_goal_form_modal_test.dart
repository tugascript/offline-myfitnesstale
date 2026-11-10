import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/cubits/macro_tracking_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/macro_tracking_dto.dart';
import 'package:myfitnesstale/src/services/inputs/macro_goal_input.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/core/sizes/screen_size.dart';
import 'package:myfitnesstale/src/widgets/macros/goals/macro_goal_form_modal.dart';

class _Macros extends MacroTrackingCubit {
  MacroGoalInput? submitted;
  int? updatedId;

  @override
  Future<bool> createMacroGoal(MacroGoalInput input) async {
    submitted = input;
    return true;
  }

  @override
  Future<bool> updateMacroGoal(int id, MacroGoalInput input) async {
    submitted = input;
    updatedId = id;
    return true;
  }
}

void main() {
  final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.xs);
  final checkbox = find.byKey(
    const ValueKey('macro-goal-calculate-calories-checkbox'),
  );
  Finder field(String name) => find.descendant(
    of: find.byKey(ValueKey('macro-goal-$name-input')),
    matching: find.byType(TextFormField),
  );
  String calories(WidgetTester tester) =>
      tester.widget<TextFormField>(field('calories')).controller!.text;

  Future<_Macros> open(WidgetTester tester, {MacroGoalDto? goal}) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final macros = _Macros();
    addTearDown(macros.close);
    await tester.pumpWidget(
      BlocProvider<MacroTrackingCubit>.value(
        value: macros,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => BlocProvider<MacroTrackingCubit>.value(
                      value: macros,
                      child: MacroGoalFormModal(
                        sizes: sizes,
                        theme: Theme.of(context),
                        existingGoal: goal,
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return macros;
  }

  testWidgets(
    'calculation defaults on, updates live, and saves calculated calories',
    (tester) async {
      final macros = await open(tester);
      expect(tester.widget<CheckboxListTile>(checkbox).value, isTrue);
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: field('calories'),
                matching: find.byType(TextField),
              ),
            )
            .readOnly,
        isTrue,
      );
      expect(calories(tester), '1985');
      await tester.enterText(field('protein'), '100');
      await tester.enterText(field('carbs'), '250');
      await tester.enterText(field('fat'), '50');
      await tester.pump();
      expect(calories(tester), '1850');
      await tester.tap(find.byKey(const ValueKey('macro-goal-submit-button')));
      await tester.pumpAndSettle();
      expect(macros.submitted?.targetCalories, 1850);
      expect(macros.submitted?.targetProtein, 100);
      expect(macros.submitted?.targetCarbs, 250);
      expect(macros.submitted?.targetFat, 50);
    },
  );

  testWidgets(
    'existing goals preserve manual calories and can toggle calculation',
    (tester) async {
      final macros = await open(
        tester,
        goal: const MacroGoalDto(
          id: 9,
          name: 'Existing goal',
          targetCalories: 2000,
          targetProtein: 100,
          targetCarbs: 100,
          targetFat: 50,
          isActive: true,
          phase: WeightGoalPhase.maintain,
        ),
      );
      expect(calories(tester), '2000');
      expect(macros.submitted, isNull);
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: field('calories'),
                matching: find.byType(TextField),
              ),
            )
            .readOnly,
        isFalse,
      );
      await tester.enterText(field('calories'), '1800');
      await tester.enterText(field('protein'), '150');
      expect(calories(tester), '1800');
      await tester.tap(checkbox);
      await tester.pump();
      expect(calories(tester), '1450');
      await tester.tap(checkbox);
      await tester.pump();
      await tester.enterText(field('calories'), '1900');
      await tester.tap(find.byKey(const ValueKey('macro-goal-submit-button')));
      await tester.pumpAndSettle();
      expect(macros.updatedId, 9);
      expect(macros.submitted?.targetCalories, 1900);
    },
  );

  testWidgets('invalid macros cannot save a misleading calculated total', (
    tester,
  ) async {
    final macros = await open(tester);
    for (final value in ['', '-1', 'abc', '1.5']) {
      await tester.enterText(field('protein'), value);
      await tester.pump();
      expect(calories(tester), isEmpty);
      final submit = find.byKey(const ValueKey('macro-goal-submit-button'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      expect(macros.submitted, isNull);
    }
    await tester.ensureVisible(field('protein'));
    await tester.enterText(field('protein'), '0');
    await tester.pump();
    expect(calories(tester), '1385');
  });

  testWidgets(
    'switches to calorie cycling, validates 7-day coverage, and submits day groups',
    (tester) async {
      final macros = await open(tester);
      await tester.tap(find.byKey(const ValueKey('macro-goal-type-cycling')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('macro-goal-day-group-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('macro-goal-day-group-1')),
        findsOneWidget,
      );

      // Unselect Sunday (day 7) from group 1 -> missing day validation prevents submit
      final sundayChip = find.byKey(const ValueKey('macro-goal-group-1-day-7'));
      await tester.ensureVisible(sundayChip);
      await tester.tap(sundayChip);
      await tester.pump();

      final submit = find.byKey(const ValueKey('macro-goal-submit-button'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      expect(macros.submitted, isNull);
      expect(
        find.byKey(const ValueKey('macro-goal-days-error')),
        findsOneWidget,
      );

      // Re-select Sunday in group 1 and submit
      await tester.ensureVisible(sundayChip);
      await tester.tap(sundayChip);
      await tester.pump();

      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(macros.submitted, isNotNull);
      expect(macros.submitted!.goalType, MacroGoalType.calorieCycling);
      expect(macros.submitted!.days.length, 2);
      expect(macros.submitted!.days[0].days.length, 5);
      expect(macros.submitted!.days[1].days.length, 2);
    },
  );

  testWidgets(
    'switching from flat to cycling seeds cycling groups with edited flat values',
    (tester) async {
      final macros = await open(tester);
      await tester.enterText(field('protein'), '222');
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('macro-goal-type-cycling')));
      await tester.pumpAndSettle();

      // Switch back to flat, edit protein again, and switch back to cycling
      await tester.tap(find.byKey(const ValueKey('macro-goal-type-flat')));
      await tester.pumpAndSettle();
      await tester.enterText(field('protein'), '240');
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('macro-goal-type-cycling')));
      await tester.pumpAndSettle();

      final submit = find.byKey(const ValueKey('macro-goal-submit-button'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(macros.submitted, isNotNull);
      expect(macros.submitted!.goalType, MacroGoalType.calorieCycling);
      expect(macros.submitted!.days[0].targetProtein, 240);
      expect(macros.submitted!.days[1].targetProtein, 240);
    },
  );

  testWidgets(
    'editing existing flat and cycling goals preserves unexposed metadata (name, fiber, sodium)',
    (tester) async {
      // 1. Flat goal edit preserves fiber and sodium
      final flatMacros = await open(
        tester,
        goal: const MacroGoalDto(
          id: 11,
          name: 'Flat With Micros',
          targetCalories: 2000,
          targetProtein: 160,
          targetCarbs: 200,
          targetFat: 60,
          targetFiber: 35,
          targetSodium: 2300,
          targetWaterIntakeMl: 2500,
          goalType: MacroGoalType.flat,
          days: [
            DayMacroGoalDto(
              id: 1,
              weekMacroGoalId: 11,
              days: DayOfWeek.values,
              name: 'Flat With Micros',
              targetCalories: 2000,
              targetProtein: 160,
              targetCarbs: 200,
              targetFat: 60,
              targetFiber: 35,
              targetSodium: 2300,
              targetWaterIntakeMl: 2500,
            ),
          ],
          isActive: true,
          phase: WeightGoalPhase.cut,
        ),
      );
      final submitFlat = find.byKey(const ValueKey('macro-goal-submit-button'));
      await tester.ensureVisible(submitFlat);
      await tester.tap(submitFlat);
      await tester.pumpAndSettle();

      expect(flatMacros.updatedId, 11);
      expect(flatMacros.submitted?.targetFiber.value, 35);
      expect(flatMacros.submitted?.targetSodium.value, 2300);
      expect(flatMacros.submitted?.days.first.targetFiber.value, 35);
      expect(flatMacros.submitted?.days.first.targetSodium.value, 2300);

      // 2. Cycling goal edit preserves day group name, fiber, sodium, and phase
      final cyclingMacros = await open(
        tester,
        goal: const MacroGoalDto(
          id: 12,
          name: 'Cycling With Metadata',
          targetCalories: 2000,
          targetProtein: 160,
          targetCarbs: 193,
          targetFat: 63,
          targetFiber: 32,
          targetSodium: 2400,
          targetWaterIntakeMl: 2500,
          goalType: MacroGoalType.calorieCycling,
          days: [
            DayMacroGoalDto(
              id: 10,
              weekMacroGoalId: 12,
              days: [
                DayOfWeek.monday,
                DayOfWeek.tuesday,
                DayOfWeek.wednesday,
                DayOfWeek.thursday,
                DayOfWeek.friday,
              ],
              name: 'Training Days',
              targetCalories: 1800,
              targetProtein: 160,
              targetCarbs: 150,
              targetFat: 60,
              targetFiber: 30,
              targetSodium: 2200,
              phase: WeightGoalPhase.cut,
            ),
            DayMacroGoalDto(
              id: 11,
              weekMacroGoalId: 12,
              days: [DayOfWeek.saturday, DayOfWeek.sunday],
              name: 'Refeed Days',
              targetCalories: 2500,
              targetProtein: 160,
              targetCarbs: 300,
              targetFat: 70,
              targetFiber: 38,
              targetSodium: 2900,
              phase: WeightGoalPhase.cut,
            ),
          ],
          isActive: true,
          phase: WeightGoalPhase.cut,
        ),
      );

      final submitCycling = find.byKey(
        const ValueKey('macro-goal-submit-button'),
      );
      await tester.ensureVisible(submitCycling);
      await tester.tap(submitCycling);
      await tester.pumpAndSettle();

      expect(cyclingMacros.updatedId, 12);
      expect(cyclingMacros.submitted?.days[0].name, 'Training Days');
      expect(cyclingMacros.submitted?.days[0].targetCalories, 1800);
      expect(cyclingMacros.submitted?.days[0].targetFiber.value, 30);
      expect(cyclingMacros.submitted?.days[0].targetSodium.value, 2200);
      expect(cyclingMacros.submitted?.days[1].name, 'Refeed Days');
      expect(cyclingMacros.submitted?.days[1].targetCalories, 2500);
      expect(cyclingMacros.submitted?.days[1].targetFiber.value, 38);
      expect(cyclingMacros.submitted?.days[1].targetSodium.value, 2900);
      expect(cyclingMacros.submitted?.targetFiber.value, 32);
      expect(cyclingMacros.submitted?.targetSodium.value, 2400);
    },
  );

  testWidgets('manual cycling calories reject non-integer or negative values', (
    tester,
  ) async {
    final macros = await open(tester);
    await tester.tap(find.byKey(const ValueKey('macro-goal-type-cycling')));
    await tester.pumpAndSettle();

    final group0Checkbox = find.byKey(
      const ValueKey('macro-goal-group-0-calculate-calories-checkbox'),
    );
    await tester.ensureVisible(group0Checkbox);
    await tester.tap(group0Checkbox);
    await tester.pump();

    final group0Calories = find.descendant(
      of: find.byKey(const ValueKey('macro-goal-group-0-calories-input')),
      matching: find.byType(TextFormField),
    );
    final submit = find.byKey(const ValueKey('macro-goal-submit-button'));

    for (final invalid in ['1800.5', '-100', 'abc', '']) {
      await tester.ensureVisible(group0Calories);
      await tester.enterText(group0Calories, invalid);
      await tester.pump();

      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      expect(macros.submitted, isNull);
    }

    await tester.ensureVisible(group0Calories);
    await tester.enterText(group0Calories, '1850');
    await tester.pump();

    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(macros.submitted, isNotNull);
    expect(macros.submitted!.days[0].targetCalories, 1850);
  });
}
