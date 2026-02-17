import 'package:flutter/material.dart';

import '../../../../utilities/sizes/data_display_sizes.dart';
import '../editors/reps_input.dart';
import '../editors/rest_input.dart';
import '../editors/set_exercise_search_modal.dart';
import '../editors/sets_input.dart';
import 'set_editor_data.dart';

class BasicSetEditor extends StatelessWidget {
  final SetEditorData setData;
  final DataDisplaySizesList sizes;
  final TextEditingController? minSetsController;
  final TextEditingController? maxSetsController;
  final TextEditingController? minRepsController;
  final TextEditingController? maxRepsController;
  final TextEditingController? restController;
  final TextEditingController? maxRestController;
  final ValueChanged<(int, String)>? onExerciseChanged;
  final ValueChanged<String>? onMinSetsChanged;
  final ValueChanged<String>? onMaxSetsChanged;
  final ValueChanged<String>? onMinRepsChanged;
  final ValueChanged<String>? onMaxRepsChanged;
  final ValueChanged<bool?>? onToMaxRepsChanged;
  final ValueChanged<String>? onRestChanged;
  final ValueChanged<String>? onMaxRestChanged;

  const BasicSetEditor({
    super.key,
    required this.setData,
    required this.sizes,
    this.minSetsController,
    this.maxSetsController,
    this.minRepsController,
    this.maxRepsController,
    this.restController,
    this.maxRestController,
    this.onToMaxRepsChanged,
    this.onExerciseChanged,
    this.onMinSetsChanged,
    this.onMaxSetsChanged,
    this.onMinRepsChanged,
    this.onMaxRepsChanged,
    this.onRestChanged,
    this.onMaxRestChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: SetsInput(
                    initialMinSets: setData.minSets,
                    initialMaxSets: setData.maxSets,
                    minSetsController: minSetsController,
                    minSetsOnChanged: onMinSetsChanged,
                    maxSetsController: maxSetsController,
                    maxSetsOnChanged: onMaxSetsChanged,
                    sizes: sizes,
                    theme: theme,
                  ),
                ),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  child: RepsInput(
                    initialMinReps: setData.minReps,
                    initialMaxReps: setData.maxReps,
                    minRepsController: minRepsController,
                    minRepsOnChanged: onMinRepsChanged,
                    maxRepsController: maxRepsController,
                    maxRepsOnChanged: onMaxRepsChanged,
                    sizes: sizes,
                    theme: theme,
                    toMaxReps: setData.toMaxReps,
                    onToMaxRepsChanged: onToMaxRepsChanged,
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing),
            _ExerciseSelectionButton(
              exerciseName: setData.exerciseName,
              sizes: sizes,
              theme: theme,
              onPressed: () {
                if (onExerciseChanged == null) {
                  return;
                }

                showDialog(
                  context: context,
                  builder: (context) {
                    return SetExerciseSearchModal(
                      sizes: sizes,
                      isLoading: false,
                      onExerciseSelected: (id, name) {
                        onExerciseChanged!((id, name));
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(height: sizes.spacing),
            RestInput(
              initialRest: setData.recommendedRestSecs,
              initialMaxRest: setData.maxRestSecs,
              restController: restController,
              restOnChanged: onRestChanged,
              maxRestController: maxRestController,
              maxRestOnChanged: onMaxRestChanged,
              sizes: sizes,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSelectionButton extends StatelessWidget {
  final String? exerciseName;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final VoidCallback onPressed;

  const _ExerciseSelectionButton({
    required this.exerciseName,
    required this.sizes,
    required this.theme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.fitness_center, size: sizes.fontSize * 1.2),
        SizedBox(width: sizes.spacing),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: theme.scaffoldBackgroundColor,
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(
                color: theme.colorScheme.primary,
                width: 0.5,
              ),
            ),
            onPressed: onPressed,
            child: Text(
              exerciseName == null ? "Select Exercise" : exerciseName!,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: sizes.subtitleFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
