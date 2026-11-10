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
import '../../../models/sqlite/workout_plan_week_model.dart';
import '../../../utils/enums.dart';
import '../../core/inputs/input.dart';

final class WorkoutPlanWeekInput extends Equatable
    implements ModelInput<WorkoutPlanWeek> {
  final int startWeek;
  final int endWeek;
  final Nullable<WorkoutPhase> phase;
  final WorkoutPlanWeekScheduleMode scheduleMode;

  const WorkoutPlanWeekInput({
    required this.startWeek,
    required this.endWeek,
    this.phase = const Nullable<WorkoutPhase>(null),
    this.scheduleMode = WorkoutPlanWeekScheduleMode.manual,
  });

  @override
  List<Object?> get props => [startWeek, endWeek, phase, scheduleMode];
}
