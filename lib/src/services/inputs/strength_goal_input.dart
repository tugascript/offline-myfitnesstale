import '../../common/nullable.dart';
import '../../models/enums.dart';

class StrengthGoalInput {
  final int exerciseId;
  final String name;
  final int targetReps;
  final int targetWeight;
  final int targetMaxStrength;
  final DateTime startDate;
  final ProgressStatus status;
  final Nullable<DateTime> completedAt;
  const StrengthGoalInput({
    required this.exerciseId,
    required this.name,
    required this.targetReps,
    required this.targetWeight,
    required this.targetMaxStrength,
    required this.startDate,
    this.status = ProgressStatus.inProgress,
    this.completedAt = const Nullable(null),
  });
}
