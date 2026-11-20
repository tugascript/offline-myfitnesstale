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
import '../max_strength_label.dart';
import '../relative_date_label.dart';
import '../exercise_record_reps.dart';

class ExerciseProgressRecordCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Units units;
  final ExerciseRecordDto record;
  final ValueChanged<int> onTapExercise;

  const ExerciseProgressRecordCard({
    super.key,
    required this.sizes,
    required this.units,
    required this.record,
    required this.onTapExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('exercise-progress-record-${record.id}'),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(vertical: sizes.margins / 2),
      child: InkWell(
        onTap: () => onTapExercise(record.exerciseId),
        child: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Column(
            children: [
              if (record.exercise != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_gymnastics,
                            size: sizes.iconSubtitleFontSize,
                          ),
                          Flexible(
                            child: Text(
                              ' ${record.exercise!.name}',
                              style: TextStyle(
                                fontSize: sizes.subtitleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: sizes.iconSubtitleFontSize,
                      color: Colors.grey,
                    ),
                  ],
                ),
                SizedBox(height: sizes.spacing),
              ],
              LayoutBuilder(
                builder: (context, constraints) => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth.isFinite
                          ? constraints.maxWidth
                          : 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: sizes.halfSpacing,
                      children: [
                        RelativeDateLabel(
                          units: units,
                          date: record.recordDate,
                          fontSize: sizes.fontSize,
                        ),
                        ExerciseRecordReps(
                          units: units,
                          fontSize: sizes.fontSize,
                          reps: record.reps,
                          weight: record.weight,
                        ),
                        MaxStrengthLabel(
                          units: units,
                          maxStrength: record.maxStrength,
                          fontSize: sizes.subtitleFontSize,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
