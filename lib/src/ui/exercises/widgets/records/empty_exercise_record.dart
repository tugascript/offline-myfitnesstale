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

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import './editors/create_exercise_record_modal.dart';

class EmptyExerciseRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final String exerciseName;
  final Units units;
  final int exerciseId;

  const EmptyExerciseRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.exerciseName,
    required this.units,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => CreateExerciseRecordModal(
                theme: theme,
                sizes: sizes,
                units: units,
                exerciseId: exerciseId,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: sizes.padding * 2,
              horizontal: sizes.padding,
            ),
            child: Column(
              children: [
                Icon(Icons.fitness_center, size: sizes.titleFontSize * 2),
                SizedBox(height: sizes.spacing),
                Text(
                  "No $exerciseName records",
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[200]
                        : Colors.grey[800],
                  ),
                ),
                SizedBox(height: sizes.spacing),
                Text(
                  "Tap to add your first record",
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
