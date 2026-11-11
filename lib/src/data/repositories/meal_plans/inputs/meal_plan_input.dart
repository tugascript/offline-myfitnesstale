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
import '../../../models/sqlite/meal_plan_model.dart';
import '../../core/inputs/input.dart';
import 'meal_plan_week_input.dart';

final class MealPlanInput extends Equatable implements ModelInput<MealPlan> {
  final String name;
  final Nullable<String> description;
  final List<MealPlanWeekInput> weeks;

  const MealPlanInput({
    required this.name,
    this.description = const Nullable(null),
    required this.weeks,
  });

  @override
  List<Object?> get props => [name, description, weeks];
}
