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

import '../../core/inputs/input.dart';
import '../../../models/sqlite/meal_plan_week_model.dart';
import '../../../utils/enums.dart';
import 'meal_plan_day_input.dart';

final class MealPlanWeekInput extends Equatable
    implements ModelInput<MealPlanWeek> {
  final int weekNumber;
  final MealPlanPhase phase;
  final List<MealPlanDayInput> days;

  const MealPlanWeekInput({
    required this.weekNumber,
    required this.phase,
    this.days = const [],
  });

  @override
  List<Object?> get props => [weekNumber, phase, days];
}
