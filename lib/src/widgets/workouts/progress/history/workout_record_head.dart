import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../models/enums.dart';
import '../../../../services/dtos/workout_record_dto.dart';
import '../../../../utilities/converters.dart';
import '../../../../utilities/formatters.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/muscles_wrap.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: sizes.fontSize * 1.2,
                    ),
                    Text(
                      " ${Formatters.formatDateTime(
                        units,
                        workoutRecord?.startedAt ?? DateTime.now(),
                      )}",
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (workoutRecord?.completedAt != null)
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: sizes.fontSize * 1.2,
                      ),
                      Text(
                        " ${Formatters.formatDuration(
                          workoutRecord!.completedAt!
                              .difference(
                                workoutRecord!.startedAt,
                              )
                              .inSeconds,
                        )}",
                        style: TextStyle(
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                  leading: Icon(Icons.scale, size: sizes.fontSize * 1.2),
                  name: 'Volume',
                  total: units == Units.metric
                      ? Converters.gramsToKg(
                          workoutRecord?.totalVolume ?? 0,
                        ).round()
                      : Converters.gramsToLbs(
                          workoutRecord?.totalVolume ?? 0,
                        ).round(),
                  fontSize: sizes.fontSize,
                ),
              ),
              Expanded(
                child: TotalString(
                  leading: Icon(Icons.timer, size: sizes.fontSize * 1.2),
                  name: 'Rest',
                  total: Formatters.formatDuration(
                      workoutRecord?.totalRestSecs ?? 0),
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
          SizedBox(height: sizes.spacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: MusclesWrap(
                  leading: Text(
                    '💪',
                    style: TextStyle(fontSize: sizes.subtitleFontSize * 1.2),
                  ),
                  title: 'Primary Muscles',
                  sizes: sizes,
                  muscles: workoutRecord?.muscles.primary ?? {},
                  theme: theme,
                ),
              ),
              if (workoutRecord?.muscles.secondary.isNotEmpty ?? false)
                Expanded(
                  child: MusclesWrap(
                    leading: Text(
                      '🥈',
                      style: TextStyle(
                        fontSize: sizes.subtitleFontSize * 1.2,
                      ),
                    ),
                    title: 'Secondary Muscles',
                    sizes: sizes,
                    muscles: workoutRecord!.muscles.secondary,
                    theme: theme,
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
