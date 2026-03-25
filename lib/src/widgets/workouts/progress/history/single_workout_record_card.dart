import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/enums.dart';
import '../../../../services/dtos/workout_record_dto.dart';
import '../../../../utilities/formatters.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/total_numeric_string.dart';
import '../../../layout/list_card.dart';

class SingleWorkoutRecordCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final Units units;

  final WorkoutRecordDto workoutRecord;

  const SingleWorkoutRecordCard({
    super.key,
    required this.sizes,
    required this.units,
    required this.workoutRecord,
  });

  @override
  Widget build(BuildContext context) {
    return ListCard(
      margin: sizes.margins,
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
          children: [
            TotalNumericString(
              leading: Icon(Icons.scale, size: sizes.fontSize * 1.2),
              name: 'Volume',
              total: workoutRecord.totalVolume,
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
