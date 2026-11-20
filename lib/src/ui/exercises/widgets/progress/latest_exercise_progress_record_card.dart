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

import '../../../../data/repositories/exercises/dtos/exercise_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import './exercise_progress_head.dart';

class LatestExerciseProgressRecordCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;

  final bool isLoading;
  final ExerciseRecordDto? exerciseRecord;
  final Future<void> Function(int exerciseId) onOpenExerciseRecords;

  const LatestExerciseProgressRecordCard({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    required this.exerciseRecord,
    required this.onOpenExerciseRecords,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('latest-exercise-progress-card'),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: isLoading || exerciseRecord == null
            ? null
            : () => onOpenExerciseRecords(exerciseRecord!.exerciseId),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.padding,
              vertical: sizes.padding * 2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: Text(
                        "Latest Record",
                        style: TextStyle(
                          fontSize: sizes.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: sizes.titleIconSize,
                      color: Colors.grey,
                    ),
                  ],
                ),
                SizedBox(height: sizes.spacing),
                ExerciseProgressHead(
                  sizes: sizes,
                  theme: theme,
                  units: units,
                  isLoading: isLoading,
                  exerciseRecord: exerciseRecord,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
