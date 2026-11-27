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

import 'package:equatable/equatable.dart';

import '../../../../utils/nullable.dart';
import '../../../models/sqlite/workout_cardio_set_record_model.dart';
import '../../core/inputs/input.dart';

final class WorkoutCardioSetRecordInput extends Equatable
    implements ModelInput<WorkoutCardioSetRecord> {
  final int workoutCardioSetId;
  final int workoutRecordId;
  final int roundNumber;
  final DateTime startedAt;
  final Nullable<int> totalRestSecs;
  final Nullable<DateTime> completedAt;

  const WorkoutCardioSetRecordInput({
    required this.workoutCardioSetId,
    required this.workoutRecordId,
    required this.roundNumber,
    required this.startedAt,
    this.totalRestSecs = const Nullable<int>(null),
    this.completedAt = const Nullable<DateTime>(null),
  });

  @override
  List<Object?> get props => [
    workoutCardioSetId,
    workoutRecordId,
    roundNumber,
    startedAt,
    totalRestSecs,
    completedAt,
  ];
}
