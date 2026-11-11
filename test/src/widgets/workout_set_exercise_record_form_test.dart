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

import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/core/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/ui/workouts/widgets/progress/workout_set_exercise_record_form.dart';

void main() {
  const sizes = DataDisplaySizesList(
    padding: 12,
    viewPadding: 10,
    spacing: 12,
    margins: 12,
    titleFontSize: 20,
    subtitleFontSize: 16,
    fontSize: 14,
    smallFontSize: 12,
    inputSpacing: 8,
    buttonSize: 40,
    buttonIconSize: 18,
    elevation: 1,
  );

  testWidgets('manual records accept decimal weight and typed reps', (
    tester,
  ) async {
    double capturedWeight = -1;
    int capturedReps = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => WorkoutSetExerciseRecordForm(
              theme: Theme.of(context),
              sizes: sizes,
              units: Units.metric,
              isLoading: false,
              initialWeight: 0,
              initialReps: 0,
              initialDifficulty: 2,
              initialDifficultyType: WorkoutSetExerciseDifficultyType.rir,
              onValuesChanged:
                  ({
                    required weight,
                    required reps,
                    required WorkoutSetExerciseDifficulty difficulty,
                  }) {
                    capturedWeight = weight;
                    capturedReps = reps;
                  },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final weightField = find.descendant(
      of: find.byKey(const ValueKey('manual-weight-input')),
      matching: find.byType(TextFormField),
    );
    final repsField = find.descendant(
      of: find.byKey(const ValueKey('manual-reps-input')),
      matching: find.byType(TextFormField),
    );

    final weightEditable = find.descendant(
      of: weightField,
      matching: find.byType(EditableText),
    );

    expect(tester.widget<EditableText>(weightEditable).readOnly, isFalse);
    expect(
      tester.widget<EditableText>(weightEditable).keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );

    await tester.enterText(weightField, '100.125');
    await tester.enterText(repsField, '8');

    expect(capturedWeight, 100.125);
    expect(capturedReps, 8);
  });
}
