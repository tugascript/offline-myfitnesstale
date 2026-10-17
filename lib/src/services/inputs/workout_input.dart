import '../../common/nullable.dart';
import '../../models/common.dart';
import '../../models/enums.dart';
import '../dtos/exercise_dto.dart';

class WorkoutInput {
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

class WorkoutSetExerciseInput {
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

class WorkoutSetExerciseRegistrationInput {
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

class WorkoutSetRegistrationInput {
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

class WorkoutRegistrationInput {
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
