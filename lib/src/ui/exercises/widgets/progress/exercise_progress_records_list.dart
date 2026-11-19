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

import '../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../data/repositories/exercises/dtos/exercise_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/utils/json_data.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/layout/list_card.dart';
import '../../../core/widgets/not_found_list.dart';
import '../../view_models/states/exercise_record_state.dart';

final _skeletonExerciseRecord = ExerciseRecordDto(
  id: 0,
  exerciseId: 0,
  weight: 100000,
  reps: 8,
  maxStrength: 126667,
  recordDate: DateTime(2026, 1, 1),
  exercise: const ExerciseDto(
    id: 0,
    name: 'Loading Exercise Name...',
    description: '',
    muscleGroup: MuscleGroup.push,
    muscles: TargetMuscles(primary: {}, secondary: {}),
    createdBy: CreatedBy.system,
  ),
);

void _noopTap(int _) {}

class ExerciseProgressRecordsList extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final bool isLoading;
  final List<ExerciseRecordDto> exerciseRecords;
  final ExerciseRecordPagination pagination;
  final ScrollController? scrollController;
  final ValueChanged<int> onTapExercise;

  const ExerciseProgressRecordsList({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.isLoading,
    required this.exerciseRecords,
    required this.pagination,
    this.scrollController,
    required this.onTapExercise,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && exerciseRecords.isEmpty) {
      return NotFoundList(
        sizes: sizes,
        message: 'No exercise records found',
        icon: Icons.history,
      );
    }

    final isInitialLoading =
        isLoading && (exerciseRecords.isEmpty || pagination.exerciseId != null);
    final hasMore = exerciseRecords.length < pagination.total;
    final showLoadingMore =
        isLoading && !isInitialLoading && exerciseRecords.isNotEmpty && hasMore;

    return Skeletonizer(
      enabled: isInitialLoading,
      child: ListView.builder(
        controller: scrollController,
        itemCount: isInitialLoading
            ? 3
            : exerciseRecords.length + (showLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (isInitialLoading) {
            return _ExerciseProgressRecordCard(
              theme: theme,
              sizes: sizes,
              units: units,
              record: _skeletonExerciseRecord,
              onTapExercise: _noopTap,
            );
          }

          if (index == exerciseRecords.length) {
            return Skeletonizer(
              enabled: true,
              child: _ExerciseProgressRecordCard(
                theme: theme,
                sizes: sizes,
                units: units,
                record: _skeletonExerciseRecord,
                onTapExercise: _noopTap,
              ),
            );
          }

          return _ExerciseProgressRecordCard(
            theme: theme,
            sizes: sizes,
            units: units,
            record: exerciseRecords[index],
            onTapExercise: onTapExercise,
          );
        },
      ),
    );
  }
}

class _ExerciseProgressRecordCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final ExerciseRecordDto record;
  final ValueChanged<int> onTapExercise;

  const _ExerciseProgressRecordCard({
    required this.theme,
    required this.sizes,
    required this.units,
    required this.record,
    required this.onTapExercise,
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
    final isDarkTheme = theme.brightness == Brightness.dark;
    final labelColor = isDarkTheme ? Colors.grey[400] : Colors.grey[600];

    return ListCard(
      key: ValueKey('exercise-progress-record-${record.id}'),
      margin: sizes.margins / 2,
      padding: sizes.padding,
      onTap: () => onTapExercise(record.exerciseId),
      children: [
        if (record.exercise != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sports_gymnastics, size: sizes.subtitleFontSize * 1.2),
              Flexible(
                child: Text(
                  " ${record.exercise!.name}",
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
                      " ${Formatters.formatRelativeDate(units, record.recordDate)}",
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
                  " ${_formatWeight(record.maxStrength)}",
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
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: _RecordMetric(
                icon: Icons.scale,
                label: 'Weight',
                value: _formatWeight(record.weight),
                fontSize: sizes.fontSize,
                labelColor: labelColor,
                valueColor: theme.colorScheme.onSurface,
              ),
            ),
            Expanded(
              child: _RecordMetric(
                icon: Icons.repeat_one,
                label: 'Reps',
                value: '${record.reps}',
                fontSize: sizes.fontSize,
                labelColor: labelColor,
                valueColor: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecordMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double fontSize;
  final Color? labelColor;
  final Color valueColor;

  const _RecordMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.fontSize,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: fontSize * 1.2),
        SizedBox(width: fontSize / 4),
        Flexible(
          child: Text.rich(
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontSize: fontSize,
                color: labelColor,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(fontSize: fontSize, color: valueColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
