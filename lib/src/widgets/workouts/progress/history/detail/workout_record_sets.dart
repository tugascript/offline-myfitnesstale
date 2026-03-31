import 'package:flutter/material.dart';

import '../../../../../models/enums.dart';
import '../../../../../services/dtos/workout_set_dto.dart';
import '../../../../../services/dtos/workout_set_record_dto.dart';
import '../../../../../utilities/sizes/data_display_sizes.dart';
import 'workout_record_set_group.dart';

final class WorkoutRecordSetsData {
  final WorkoutSetDto workoutSet;
  final List<WorkoutSetRecordDto> setRecords;

  const WorkoutRecordSetsData({
    required this.workoutSet,
    required this.setRecords,
  });
}

class WorkoutRecordSets extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;

  final List<WorkoutRecordSetsData> data;

  const WorkoutRecordSets({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Sets',
            style: TextStyle(
              fontSize: sizes.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: sizes.spacing),
          for (int i = 0; i < data.length; i++)
            WorkoutRecordSetGroup(
              sizes: sizes,
              theme: theme,
              isDarkTheme: theme.brightness == Brightness.dark,
              units: units,
              workoutSet: data[i].workoutSet,
              setRecords: data[i].setRecords,
              initiallyExpanded: i == 0,
            ),
        ],
      ),
    );
  }
}
