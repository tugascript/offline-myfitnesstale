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
import '../../exercises/dtos/exercise_dto.dart';

final class WorkoutInput {
  final String name;
  final Difficulty difficulty;
  final EditorType editorType;
  final bool isFavorite;
  final Nullable<String> description;
  final Nullable<PictureData> picture;
  final Nullable<VideoData> video;
  final Nullable<WorkoutPhase> phase;

  const WorkoutInput({
    required this.name,
    required this.difficulty,
    this.editorType = EditorType.basic,
    this.isFavorite = false,
    this.description = const Nullable<String>(null),
    this.picture = const Nullable<PictureData>(null),
    this.video = const Nullable<VideoData>(null),
    this.phase = const Nullable<WorkoutPhase>(null),
  });
}

final class WorkoutSetExerciseInput {
  final int exerciseId;
  final int minReps;
  final int? maxReps;
  final bool toMaxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final List<int>? alternativeExerciseIds;

  const WorkoutSetExerciseInput({
    required this.exerciseId,
    required this.minReps,
    this.maxReps,
    this.toMaxReps = false,
    this.difficulty,
    this.alternativeExerciseIds,
  });
}

final class WorkoutSetExerciseUpsertInput {
  final int? id;
  final int exerciseId;
  final int position;
  final int minReps;
  final int? maxReps;
  final bool toMaxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final List<int>? alternativeExerciseIds;

  const WorkoutSetExerciseUpsertInput({
    this.id,
    required this.exerciseId,
    required this.position,
    required this.minReps,
    this.maxReps,
    this.toMaxReps = false,
    this.difficulty,
    this.alternativeExerciseIds,
  });
}

final class WorkoutSetUpsertInput {
  final int? id;
  final WorkoutSetType setType;
  final int minSets;
  final int recommendedRestSecs;
  final List<WorkoutSetExerciseUpsertInput> exercises;
  final int position;
  final int? maxSets;
  final int? maxRestSecs;

  const WorkoutSetUpsertInput({
    this.id,
    required this.setType,
    required this.minSets,
    required this.recommendedRestSecs,
    required this.exercises,
    required this.position,
    this.maxSets,
    this.maxRestSecs,
  });
}

final class WorkoutSetExerciseRegistrationInput {
  final ExerciseDto exercise;
  final int minReps;
  final int? maxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final List<ExerciseDto> alternativeExercises;

  const WorkoutSetExerciseRegistrationInput({
    required this.exercise,
    required this.minReps,
    this.maxReps,
    this.difficulty,
    this.alternativeExercises = const [],
  });
}

final class WorkoutSetRegistrationInput {
  final WorkoutSetType setType;
  final int minSets;
  final int? maxSets;
  final int recommendedRestSecs;
  final int? maxRestSecs;
  final List<WorkoutSetExerciseRegistrationInput> exercises;

  const WorkoutSetRegistrationInput({
    required this.setType,
    required this.minSets,
    this.maxSets,
    required this.recommendedRestSecs,
    this.maxRestSecs,
    required this.exercises,
  });
}

final class WorkoutRegistrationInput {
  final String name;
  final String description;
  final PictureData? picture;
  final VideoData? video;
  final Difficulty difficulty;
  final WorkoutPhase? phase;
  final List<WorkoutSetRegistrationInput> sets;

  const WorkoutRegistrationInput({
    required this.name,
    required this.description,
    this.picture,
    this.video,
    required this.difficulty,
    this.phase,
    required this.sets,
  });
}

final class StandardSetInput {
  final int? id;
  final int minSets;
  final int maxSets;
  final int minReps;
  final int maxReps;
  final bool toMaxReps;
  final int recommendedRestSecs;
  final int maxRestSecs;
  final int exerciseId;
  final int? setExerciseId;

  const StandardSetInput({
    this.id,
    required this.minSets,
    required this.maxSets,
    required this.minReps,
    required this.maxReps,
    required this.toMaxReps,
    required this.recommendedRestSecs,
    required this.maxRestSecs,
    required this.exerciseId,
    this.setExerciseId,
  });
}

final class ComplexSetExerciseInput {
  final int? id;
  final int position;
  final int exerciseId;
  final int minReps;
  final int? maxReps;
  final bool toMaxReps;
  final WorkoutSetExerciseDifficulty? difficulty;
  final Set<int> alternativeExerciseIds;

  const ComplexSetExerciseInput({
    this.id,
    required this.position,
    required this.exerciseId,
    required this.minReps,
    this.maxReps,
    required this.toMaxReps,
    this.difficulty,
    this.alternativeExerciseIds = const {},
  });
}

final class ComplexSetInput {
  final int? id;
  final WorkoutSetType setType;
  final int position;
  final int minSets;
  final int? maxSets;
  final int recommendedRestSecs;
  final int? maxRestSecs;
  final List<ComplexSetExerciseInput> exercises;

  const ComplexSetInput({
    this.id,
    required this.setType,
    required this.position,
    required this.minSets,
    this.maxSets,
    required this.recommendedRestSecs,
    this.maxRestSecs,
    required this.exercises,
  });
}
