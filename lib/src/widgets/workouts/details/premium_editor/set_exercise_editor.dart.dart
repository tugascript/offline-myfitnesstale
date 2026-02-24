import 'package:flutter/material.dart';

import '../../../../models/enums.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../editors/set_exercise_search_modal.dart';
import 'complex_set_editor_data.dart';

class SetExerciseEditor extends StatelessWidget {
  final ComplexSetExerciseEditorData exerciseData;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final ValueChanged<(int, String)>? onExerciseChanged;
  final ValueChanged<String>? onMinRepsChanged;
  final ValueChanged<String>? onMaxRepsChanged;
  final ValueChanged<bool?>? onToMaxRepsChanged;
  final ValueChanged<WorkoutSetExerciseDifficultyType?>?
      onDifficultyTypeChanged;
  final ValueChanged<String>? onDifficultyValueChanged;
  final ValueChanged<String>? onAlternativeIdsChanged;

  const SetExerciseEditor({
    super.key,
    required this.exerciseData,
    required this.sizes,
    required this.isLoading,
    this.onExerciseChanged,
    this.onMinRepsChanged,
    this.onMaxRepsChanged,
    this.onToMaxRepsChanged,
    this.onDifficultyTypeChanged,
    this.onDifficultyValueChanged,
    this.onAlternativeIdsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difficulty = exerciseData.difficulty;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _NumericInput(
                    label: "Min Reps",
                    initialValue: exerciseData.minReps.toString(),
                    onChanged: onMinRepsChanged,
                    enabled: !isLoading,
                  ),
                ),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  child: _NumericInput(
                    label: "Max Reps",
                    initialValue: exerciseData.maxReps?.toString() ?? "",
                    onChanged: onMaxRepsChanged,
                    enabled: !isLoading,
                  ),
                ),
                SizedBox(width: sizes.spacing / 2),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "To Max",
                        style: TextStyle(fontSize: sizes.smallFontSize),
                      ),
                      Checkbox(
                        value: exerciseData.toMaxReps,
                        onChanged: isLoading ? null : onToMaxRepsChanged,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing / 2),
            OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      if (onExerciseChanged == null) {
                        return;
                      }

                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) {
                          return SetExerciseSearchModal(
                            sizes: sizes,
                            isLoading: isLoading,
                            onExerciseSelected: (id, name) {
                              onExerciseChanged!((id, name));
                              Navigator.of(dialogContext).pop();
                            },
                          );
                        },
                      );
                    },
              icon: const Icon(Icons.fitness_center),
              label: Text(
                exerciseData.exerciseName ?? "Select Exercise",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: sizes.spacing / 2),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<
                      WorkoutSetExerciseDifficultyType?>(
                    initialValue: difficulty?.type,
                    decoration: const InputDecoration(
                      labelText: "Difficulty Type",
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<WorkoutSetExerciseDifficultyType?>(
                        value: null,
                        child: Text("None"),
                      ),
                      ...WorkoutSetExerciseDifficultyType.values
                          .map((difficultyType) {
                        return DropdownMenuItem<
                            WorkoutSetExerciseDifficultyType?>(
                          value: difficultyType,
                          child: Text(difficultyType.value),
                        );
                      }),
                    ],
                    onChanged: isLoading ? null : onDifficultyTypeChanged,
                  ),
                ),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  child: _NumericInput(
                    label: "Difficulty Value",
                    initialValue: difficulty?.value.toString() ?? "",
                    onChanged: onDifficultyValueChanged,
                    enabled: !isLoading,
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing / 2),
            TextFormField(
              enabled: !isLoading,
              initialValue: exerciseData.alternativeExerciseIds.join(","),
              onChanged: onAlternativeIdsChanged,
              decoration: const InputDecoration(
                labelText: "Alternative Exercise IDs (comma separated)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumericInput extends StatelessWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const _NumericInput({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      keyboardType: TextInputType.number,
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
