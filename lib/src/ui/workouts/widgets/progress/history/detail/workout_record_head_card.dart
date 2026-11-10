// Copyright (C) 2026 afonsobarracha
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
