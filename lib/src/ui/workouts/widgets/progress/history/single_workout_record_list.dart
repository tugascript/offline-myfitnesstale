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
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../data/repositories/workouts/dtos/workout_record_dto.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/utils/converters.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/layout/list_card.dart';
import '../../../../core/widgets/not_found_list.dart';
import '../../../../core/widgets/total_numeric_string.dart';
import '../../../view_models/states/workout_record_state.dart';

class SingleWorkoutRecordList extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Units units;
  final bool isLoading;
  final int? workoutId;
  final int? workoutVersion;
  final List<WorkoutRecordDto> workoutRecords;
  final WorkoutRecordPagination pagination;
  final ScrollController? scrollController;

  const SingleWorkoutRecordList({
    super.key,
    required this.sizes,
    required this.units,
    required this.isLoading,
    this.workoutId,
    this.workoutVersion,
    required this.workoutRecords,
    required this.pagination,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && workoutRecords.isEmpty) {
      return NotFoundList(
        sizes: sizes,
        message: 'No workout records found',
        icon: Icons.history,
      );
    }

    return Skeletonizer(
      enabled: isLoading && workoutRecords.isEmpty,
      child: ListView.builder(
        controller: scrollController,
        itemCount: isLoading && workoutRecords.isEmpty
            ? 2
            : workoutRecords.length,
        itemBuilder: (context, index) {
          if (isLoading && workoutRecords.isEmpty) {
            return _SingleWorkoutRecordCard(
              sizes: sizes,
              units: units,
              workoutRecord: WorkoutRecordDto.empty(),
              workoutId: workoutId,
              workoutVersion: workoutVersion,
            );
          }

          return _SingleWorkoutRecordCard(
            sizes: sizes,
            units: units,
            workoutRecord: workoutRecords[index],
            workoutId: workoutId,
            workoutVersion: workoutVersion,
          );
        },
      ),
    );
  }
}

class _SingleWorkoutRecordCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Units units;

  final WorkoutRecordDto workoutRecord;
  final int? workoutId;
  final int? workoutVersion;

  const _SingleWorkoutRecordCard({
    required this.sizes,
    required this.units,
    required this.workoutRecord,
    required this.workoutId,
    required this.workoutVersion,
  });

  @override
  Widget build(BuildContext context) {
    return ListCard(
      margin: sizes.margins / 2,
      padding: sizes.padding,
      children: [
        if (workoutRecord.workout != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center, size: sizes.subtitleFontSize * 1.2),
              Flexible(
                child: Text(
                  " ${workoutRecord.workout!.name}",
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
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.calendar_today, size: sizes.fontSize * 1.2),
            Flexible(
              child: Text(
                " ${Formatters.formatDateTimeRange(units, workoutRecord.startedAt, workoutRecord.completedAt)}",
                style: TextStyle(
                  fontSize: sizes.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: TotalNumericString(
                leading: Icon(Icons.repeat, size: sizes.fontSize * 1.2),
                name: 'Sets',
                total: workoutRecord.totalSets,
                fontSize: sizes.fontSize,
              ),
            ),
            Expanded(
              child: TotalNumericString(
                leading: Icon(Icons.scale, size: sizes.fontSize * 1.2),
                name: 'Volume',
                total: units == Units.metric
                    ? Converters.gramsToKg(workoutRecord.totalVolume).round()
                    : Converters.gramsToLbs(workoutRecord.totalVolume).round(),
                fontSize: sizes.fontSize,
              ),
            ),
          ],
        ),
      ],
      onTap: () {
        final targetWorkoutId = workoutId ?? workoutRecord.workoutId;
        context.push(
          '/workouts/$targetWorkoutId/history/${workoutRecord.version}/records/${workoutRecord.id}',
        );
      },
    );
  }
}
