import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../services/dtos/workout_dto.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import 'workout_base_form.dart';

class WorkoutHeaderEditCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final WorkoutDto workout;
  final bool canUsePremiumEditor;
  final bool isLoading;
  final VoidCallback onCancel;
  final void Function({
    required String name,
    required bool isFavorite,
    required Difficulty difficulty,
    required EditorType editorType,
    String? description,
  }) onSubmit;

  const WorkoutHeaderEditCard({
    super.key,
    required this.theme,
    required this.sizes,
    required this.workout,
    required this.canUsePremiumEditor,
    required this.isLoading,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = theme.brightness == Brightness.dark
        ? Colors.grey[200]
        : Colors.grey[800];
    return Card(
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Edit Workout',
                  style: TextStyle(
                    fontSize: sizes.titleFountSize,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: isLoading ? null : onCancel,
                  tooltip: 'Close editor',
                  icon: const Icon(Icons.close),
                  color: textColor,
                ),
              ],
            ),
            SizedBox(height: sizes.spacing / 2),
            WorkoutBaseForm(
              theme: theme,
              sizes: sizes,
              isLoading: isLoading,
              submitLabel: 'Save Workout',
              initialName: workout.name,
              initialIsFavorite: workout.isFavorite,
              initialDifficulty: workout.difficulty,
              initialEditorType: workout.editorType,
              canUsePremiumEditor: canUsePremiumEditor,
              initialDescription: workout.description,
              onSubmit: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
