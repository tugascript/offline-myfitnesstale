import 'package:flutter/material.dart';

import '../../../../../../data/utils/enums.dart';
import '../../../../../../data/repositories/workouts/dtos/workout_record_dto.dart';
import '../../../../../core/sizes/data_display_sizes.dart';
import '../workout_record_head.dart';

class WorkoutRecordHeadCard extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;
  final bool isLoading;
  final WorkoutRecordDto? workoutRecord;

  const WorkoutRecordHeadCard({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    required this.workoutRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sizes.padding,
            vertical: sizes.padding * 2,
          ),
          child: WorkoutRecordHead(
            sizes: sizes,
            theme: theme,
            units: units,
            isLoading: isLoading,
            workoutRecord: workoutRecord,
          ),
        ),
      ),
    );
  }
}
