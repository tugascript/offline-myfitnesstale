import '../../common/nullable.dart';
import '../../models/enums.dart';

class WeightGoalInput {
  final int targetWeight;
  final Nullable<int> targetFatPercentage;
  final DateTime startDate;
  final WeightGoalPhase phase;
  final ProgressStatus status;
  final Nullable<DateTime> completedAt;

  const WeightGoalInput({
    required this.targetWeight,
    this.targetFatPercentage = const Nullable<int>(null),
    required this.startDate,
    required this.phase,
    this.status = ProgressStatus.inProgress,
    this.completedAt = const Nullable<DateTime>(null),
  });
}
