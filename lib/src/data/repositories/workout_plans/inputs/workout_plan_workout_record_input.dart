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

import '../../../models/sqlite/workout_plan_workout_record_model.dart';
import '../../../utils/enums.dart';
import '../../core/inputs/input.dart';

final class WorkoutPlanWorkoutRecordInput extends Equatable
    implements ModelInput<WorkoutPlanWorkoutRecord> {
  final int workoutPlanRecordId;
  final int workoutRecordId;
  final ProgressStatus status;
  final int? week;
  final int? weekDay;
  final int? workoutPosition;
  final DateTime? startedAt;

  const WorkoutPlanWorkoutRecordInput({
    required this.workoutPlanRecordId,
    required this.workoutRecordId,
    this.status = ProgressStatus.inProgress,
    this.week,
    this.weekDay,
    this.workoutPosition,
    this.startedAt,
  });

  @override
  List<Object?> get props => [
    workoutPlanRecordId,
    workoutRecordId,
    status,
    week,
    weekDay,
    workoutPosition,
    startedAt,
  ];
}
