import '../../common/nullable.dart';
import '../../models/common.dart';

class ExerciseRecordInput {
  final int exerciseId;
  final int weight;
  final int reps;
  final DateTime recordDate;
  final Nullable<PictureData> picture;
  final Nullable<VideoData> video;

  const ExerciseRecordInput({
    required this.exerciseId,
    required this.weight,
    required this.reps,
    required this.recordDate,
    this.picture = const Nullable<PictureData>(null),
    this.video = const Nullable<VideoData>(null),
  });
}
