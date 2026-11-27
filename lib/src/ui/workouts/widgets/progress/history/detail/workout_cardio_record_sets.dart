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

import '../../../../../../data/repositories/workouts/dtos/workout_cardio_set_dto.dart';
import '../../../../../../data/repositories/workouts/dtos/workout_cardio_set_record_dto.dart';
import '../../../../../core/sizes/data_display_sizes.dart';
import './workout_cardio_record_set_group.dart';

final class WorkoutCardioRecordSetsData {
  final WorkoutCardioSetDto workoutCardioSet;
  final List<WorkoutCardioSetRecordDto> cardioSetRecords;

  const WorkoutCardioRecordSetsData({
    required this.workoutCardioSet,
    required this.cardioSetRecords,
  });
}

class WorkoutCardioRecordSets extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final List<WorkoutCardioRecordSetsData> data;

  const WorkoutCardioRecordSets({
    super.key,
    required this.sizes,
    required this.theme,
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
            'Rounds',
            style: TextStyle(
              fontSize: sizes.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: sizes.spacing),
          for (int i = 0; i < data.length; i++)
            WorkoutCardioRecordSetGroup(
              sizes: sizes,
              theme: theme,
              isDarkTheme: theme.brightness == Brightness.dark,
              workoutCardioSet: data[i].workoutCardioSet,
              cardioSetRecords: data[i].cardioSetRecords,
              initiallyExpanded: i == 0,
            ),
        ],
      ),
    );
  }
}
