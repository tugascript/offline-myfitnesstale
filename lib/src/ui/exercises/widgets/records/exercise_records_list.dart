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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../data/repositories/exercises/dtos/exercise_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import './exercise_record_card.dart';

class ExerciseRecordsList extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;

  final ExerciseDto exercise;
  final bool isLoading;
  final bool isMutating;
  final List<ExerciseRecordDto> records;

  const ExerciseRecordsList({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.exercise,
    required this.isLoading,
    this.isMutating = false,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading && records.isEmpty,
      child: ListView.builder(
        itemCount: isLoading && records.isEmpty ? 3 : records.length,
        itemBuilder: (context, index) {
          if (isLoading && records.isEmpty) {
            return ExerciseRecordCard(
              theme: theme,
              sizes: sizes,
              units: units,
              exercise: exercise,
              record: ExerciseRecordDto.empty(),
            );
          }

          final record = records[index];
          return ExerciseRecordCard(
            theme: theme,
            sizes: sizes,
            units: units,
            exercise: exercise,
            record: record,
            isLoading: isMutating,
          );
        },
      ),
    );
  }
}
