import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../cubits/states/workout_record_state.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/workout_record_dto.dart';
import '../../../../utilities/converters.dart';
import '../../../../utilities/formatters.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/not_found_list.dart';
import '../../../common/total_numeric_string.dart';
import '../../../layout/list_card.dart';

class SingleWorkoutRecordList extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Units units;
  final bool isLoading;

  final List<WorkoutRecordDto> workoutRecords;
  final WorkoutRecordPagination pagination;
  final ScrollController? scrollController;

  const SingleWorkoutRecordList({
    super.key,
    required this.sizes,
    required this.units,
    required this.isLoading,
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
        itemCount:
            isLoading && workoutRecords.isEmpty ? 2 : workoutRecords.length,
        itemBuilder: (context, index) {
          if (isLoading && workoutRecords.isEmpty) {
            return _SingleWorkoutRecordCard(
              sizes: sizes,
              units: units,
              workoutRecord: WorkoutRecordDto.empty(),
            );
          }

          return _SingleWorkoutRecordCard(
            sizes: sizes,
            units: units,
            workoutRecord: workoutRecords[index],
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

  const _SingleWorkoutRecordCard({
    required this.sizes,
    required this.units,
    required this.workoutRecord,
  });

  @override
  Widget build(BuildContext context) {
    return ListCard(
      margin: sizes.margins / 2,
      padding: sizes.padding,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow, size: sizes.fontSize * 1.2),
                Text(
                  " ${Formatters.formatDate(units, workoutRecord.startedAt)}",
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (workoutRecord.completedAt != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stop, size: sizes.fontSize * 1.2),
                  Text(
                    " ${Formatters.formatDate(units, workoutRecord.completedAt!)}",
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TotalNumericString(
              leading: Icon(Icons.scale, size: sizes.fontSize * 1.2),
              name: 'Volume',
              total: units == Units.metric
                  ? Converters.gramsToKg(workoutRecord.totalVolume).round()
                  : Converters.gramsToLbs(workoutRecord.totalVolume).round(),
              fontSize: sizes.fontSize,
            ),
            TotalNumericString(
              leading: Icon(Icons.timer, size: sizes.fontSize * 1.2),
              name: 'Rest',
              total: workoutRecord.totalRestSecs,
              fontSize: sizes.fontSize,
            ),
          ],
        ),
        SizedBox(height: sizes.spacing),
        // Totals row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TotalNumericString(
              leading: Icon(Icons.repeat, size: sizes.fontSize * 1.2),
              name: 'Sets',
              total: workoutRecord.totalSets,
              fontSize: sizes.fontSize,
            ),
            TotalNumericString(
              leading: Icon(Icons.repeat_one, size: sizes.fontSize * 1.2),
              name: 'Reps',
              total: workoutRecord.totalReps,
              fontSize: sizes.fontSize,
            ),
          ],
        ),
        // Utility methods below the build method
      ],
      onTap: () {
        context.push('/workout-records/${workoutRecord.id}');
      },
    );
  }
}
