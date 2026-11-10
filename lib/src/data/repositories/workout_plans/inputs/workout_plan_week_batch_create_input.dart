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

import '../../../utils/enums.dart';
import '../../core/inputs/input.dart';
import 'workout_plan_day_batch_create_input.dart';

final class WorkoutPlanWeekBatchCreateInput extends Equatable implements Input {
  final int startWeek;
  final int endWeek;
  final WorkoutPhase? phase;
  final WorkoutPlanWeekScheduleMode scheduleMode;
  final List<WorkoutPlanDayBatchCreateInput> days;

  const WorkoutPlanWeekBatchCreateInput({
    required this.startWeek,
    required this.endWeek,
    this.phase,
    this.scheduleMode = WorkoutPlanWeekScheduleMode.manual,
    required this.days,
  });

  @override
  List<Object?> get props => [startWeek, endWeek, phase, scheduleMode, days];
}
