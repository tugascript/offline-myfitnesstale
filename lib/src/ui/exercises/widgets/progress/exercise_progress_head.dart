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
import '../../../core/utils/converters.dart';
import '../../../core/utils/formatters.dart';

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

  String _formatWeight(int grams) {
    final value = units == Units.metric
        ? Converters.gramsToKg(grams)
        : Converters.gramsToLbs(grams);
    final suffix = units == Units.metric ? 'kg' : 'lb';
    return '${Formatters.formatWeight(value)} $suffix';
  }

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
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: sizes.fontSize * 1.2),
                    Flexible(
                      child: Text(
                        " ${Formatters.formatRelativeDate(units, exerciseRecord?.recordDate ?? DateTime.now())}",
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sizes.spacing),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("💪", style: TextStyle(fontSize: sizes.fontSize * 1.2)),
                  Text(
                    " ${_formatWeight(exerciseRecord?.maxStrength ?? 0)}",
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: sizes.spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: _ExerciseStatText(
                  theme: theme,
                  leading: Icon(Icons.scale, size: sizes.fontSize * 1.2),
                  label: 'Weight',
                  value: _formatWeight(exerciseRecord?.weight ?? 0),
                  fontSize: sizes.fontSize,
                ),
              ),
              Expanded(
                child: _ExerciseStatText(
                  theme: theme,
                  leading: Icon(Icons.repeat_one, size: sizes.fontSize * 1.2),
                  label: 'Reps',
                  value: '${exerciseRecord?.reps ?? 0}',
                  fontSize: sizes.fontSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseStatText extends StatelessWidget {
  final ThemeData theme;
  final Widget leading;
  final String label;
  final String value;
  final double fontSize;

  const _ExerciseStatText({
    required this.theme,
    required this.leading,
    required this.label,
    required this.value,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        SizedBox(width: fontSize / 4),
        Flexible(
          child: Text.rich(
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontSize: fontSize,
                color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
