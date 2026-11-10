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
import '../../../utils/json_data.dart';
import '../../core/inputs/input.dart';
import 'workout_plan_week_registration_input.dart';

final class WorkoutPlanRegistrationInput extends Equatable implements Input {
  final String name;
  final String description;
  final PictureData? picture;
  final VideoData? video;
  final Difficulty difficulty;
  final List<WorkoutPlanWeekRegistrationInput> weeks;

  const WorkoutPlanRegistrationInput({
    required this.name,
    required this.description,
    this.picture,
    this.video,
    required this.difficulty,
    required this.weeks,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    picture,
    video,
    difficulty,
    weeks,
  ];
}
