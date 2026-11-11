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

import '../../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import './workout_base_form.dart';

class WorkoutHeaderEditCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final WorkoutDto workout;
  final bool isLoading;
  final VoidCallback onCancel;
  final void Function({
    required String name,
    required bool isFavorite,
    required Difficulty difficulty,
    required EditorType editorType,
    String? description,
  })
  onSubmit;

  const WorkoutHeaderEditCard({
    super.key,
    required this.theme,
    required this.sizes,
    required this.workout,
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
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Details',
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
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
              submitLabel: 'UPDATE WORKOUT',
              initialName: workout.name,
              initialIsFavorite: workout.isFavorite,
              initialDifficulty: workout.difficulty,
              initialEditorType: workout.editorType,
              initialDescription: workout.description,
              onSubmit: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
