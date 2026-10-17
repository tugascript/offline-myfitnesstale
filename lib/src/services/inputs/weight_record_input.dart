import '../../common/nullable.dart';

class WeightRecordInput {
  final int weight;
  final DateTime recordDate;
  final Nullable<int> fatPercentage;
  final Nullable<String> pictureUri;
  final Nullable<int> weightGoalId;

  const WeightRecordInput({
    required this.weight,
    required this.recordDate,
    this.fatPercentage = const Nullable<int>(null),
    this.pictureUri = const Nullable<String>(null),
    this.weightGoalId = const Nullable<int>(null),
  });
}
