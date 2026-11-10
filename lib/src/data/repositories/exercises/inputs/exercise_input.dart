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

import '../../../../utils/nullable.dart';
import '../../../utils/enums.dart';
import '../../../utils/json_data.dart';

final class ExerciseInput {
  final String name;
  final MuscleGroup muscleGroup;
  final TargetMuscles muscles;
  final Set<int> equipmentIds;
  final Nullable<String> description;
  final Nullable<PictureData> picture;
  final Nullable<VideoData> video;
  final Nullable<Difficulty> difficulty;
  final bool isFavorite;

  const ExerciseInput({
    required this.name,
    required this.muscleGroup,
    required this.muscles,
    this.equipmentIds = const <int>{},
    this.description = const Nullable<String>(null),
    this.picture = const Nullable<PictureData>(null),
    this.video = const Nullable<VideoData>(null),
    this.difficulty = const Nullable<Difficulty>(null),
    this.isFavorite = false,
  });
}
