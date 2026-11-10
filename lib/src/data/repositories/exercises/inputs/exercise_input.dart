import '../../../../utils/nullable.dart';
import '../../../utils/json_data.dart';
import '../../../utils/enums.dart';

class ExerciseInput {
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
