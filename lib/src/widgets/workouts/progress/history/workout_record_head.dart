import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../models/enums.dart';
import '../../../../services/dtos/workout_record_dto.dart';
import '../../../../utilities/converters.dart';
import '../../../../utilities/formatters.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/muscles_carousel.dart';
import '../../../common/total_numeric_string.dart';
import '../../../common/total_string.dart';

class WorkoutRecordHead extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;

  final bool isLoading;
  final WorkoutRecordDto? workoutRecord;

  const WorkoutRecordHead({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    required this.workoutRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading || workoutRecord == null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (workoutRecord?.workout != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center, size: sizes.subtitleFontSize * 1.2),
                Flexible(
                  child: Text(
                    " ${workoutRecord!.workout!.name}",
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
                        " ${Formatters.formatDateTimeRange(units, workoutRecord?.startedAt ?? DateTime.now(), workoutRecord?.completedAt)}",
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (workoutRecord?.completedAt != null) ...[
                SizedBox(width: sizes.spacing),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: sizes.fontSize * 1.2),
                    Text(
                      " ${Formatters.formatDuration(workoutRecord!.completedAt!.difference(workoutRecord!.startedAt).inSeconds)}",
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          SizedBox(height: sizes.spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: TotalNumericString(
                  leading: Icon(Icons.scale, size: sizes.fontSize * 1.2),
                  name: 'Volume',
                  total: units == Units.metric
                      ? Converters.gramsToKg(workoutRecord?.totalVolume ?? 0)
                            .round()
                      : Converters.gramsToLbs(workoutRecord?.totalVolume ?? 0)
                            .round(),
                  fontSize: sizes.fontSize,
                ),
              ),
              Expanded(
                child: TotalString(
                  leading: Icon(Icons.timer, size: sizes.fontSize * 1.2),
                  name: 'Rest',
                  total: Formatters.formatDuration(
                    workoutRecord?.totalRestSecs ?? 0,
                  ),
                  fontSize: sizes.fontSize,
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: TotalNumericString(
                  leading: Icon(Icons.repeat, size: sizes.fontSize * 1.2),
                  name: 'Sets',
                  total: workoutRecord?.totalSets ?? 0,
                  fontSize: sizes.fontSize,
                ),
              ),
              Expanded(
                child: TotalNumericString(
                  leading: Icon(Icons.repeat_one, size: sizes.fontSize * 1.2),
                  name: 'Reps',
                  total: workoutRecord?.totalReps ?? 0,
                  fontSize: sizes.fontSize,
                ),
              ),
            ],
          ),
          if (workoutRecord != null) ...[
            SizedBox(height: sizes.spacing),
            MusclesCarousel(
              sizes: sizes,
              theme: theme,
              muscles: workoutRecord!.muscles,
            ),
          ],
        ],
      ),
    );
  }
}
