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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/repositories/exercises/dtos/exercise_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../exercise_record_reps.dart';
import '../max_strength_label.dart';
import '../relative_date_label.dart';

class ExerciseProgressHead extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;

  final bool isLoading;
  final ExerciseRecordDto? exerciseRecord;

  const ExerciseProgressHead({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    required this.exerciseRecord,
  });

  @override
  Widget build(BuildContext context) {
    final isSkeleton = isLoading || exerciseRecord == null;

    return Skeletonizer(
      enabled: isSkeleton,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSkeleton || exerciseRecord?.exercise != null) ...[
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: sizes.halfSpacing,
                runSpacing: sizes.halfSpacing,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_gymnastics,
                        size: sizes.subtitleFontSize * 1.2,
                      ),
                      Flexible(
                        child: Text(
                          " ${exerciseRecord?.exercise?.name ?? 'Loading Exercise Name'}",
                          style: TextStyle(
                            fontSize: sizes.subtitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  RelativeDateLabel(
                    units: units,
                    date: exerciseRecord?.recordDate ?? DateTime.now(),
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
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
                    ExerciseRecordReps(
                      units: units,
                      fontSize: sizes.subtitleFontSize,
                      reps: exerciseRecord?.reps ?? 0,
                      weight: exerciseRecord?.weight ?? 0,
                    ),
                    MaxStrengthLabel(
                      units: units,
                      maxStrength: exerciseRecord?.maxStrength ?? 0,
                      fontSize: sizes.fontSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
