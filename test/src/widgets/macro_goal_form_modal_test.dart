import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/cubits/macro_tracking_cubit.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/macro_tracking_dto.dart';
import 'package:myfitnesstale/src/services/inputs/macro_goal_input.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/utilities/sizes/screen_size.dart';
import 'package:myfitnesstale/src/widgets/macro_goals/macro_goal_form_modal.dart';

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

  testWidgets('existing goals can switch to manual calories and back', (
    tester,
  ) async {
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
    expect(calories(tester), '1250');
    expect(macros.submitted, isNull);
    await tester.tap(checkbox);
    await tester.pump();
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
  });

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
}
