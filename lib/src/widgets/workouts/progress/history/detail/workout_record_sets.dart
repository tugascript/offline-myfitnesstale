import 'package:flutter/material.dart';

import '../../../../../models/enums.dart';
import '../../../../../services/dtos/workout_set_dto.dart';
import '../../../../../services/dtos/workout_set_record_dto.dart';
import '../../../../../utilities/sizes/data_display_sizes.dart';
import 'workout_record_set_group.dart';

class WorkoutRecordSetsData {
  final WorkoutSetDto workoutSet;
  final List<WorkoutSetRecordDto> setRecords;

  WorkoutRecordSetsData({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sets',
          style: TextStyle(
            fontSize: sizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing),
        for (final setData in data)
          WorkoutRecordSetGroup(
            sizes: sizes,
            theme: theme,
            isDarkTheme: theme.brightness == Brightness.dark,
            units: units,
            workoutSet: setData.workoutSet,
            setRecords: setData.setRecords,
          ),
      ],
    );
  }
}
