import '../../common/nullable.dart';
import '../../models/enums.dart';

class WorkoutPlanRecordInput {
  final int workoutPlanId;
  final ProgressStatus status;
  final DateTime? startedAt;
  final Nullable<DateTime> completedAt;

  const WorkoutPlanRecordInput({
    required this.workoutPlanId,
    this.status = ProgressStatus.inProgress,
    this.startedAt,
    this.completedAt = const Nullable<DateTime>(null),
  });
}

class WorkoutPlanDayRecordInput {
  final int workoutPlanRecordId;
  final ProgressStatus status;
  final int? week;
  final int? weekDay;

  const WorkoutPlanDayRecordInput({
    required this.workoutPlanRecordId,
    this.status = ProgressStatus.inProgress,
    this.week,
    this.weekDay,
  });
}

class WorkoutPlanWorkoutRecordInput {
  final int workoutPlanRecordId;
  final int workoutRecordId;
  final ProgressStatus status;
  final int? week;
  final int? weekDay;
  final int? workoutPosition;
  final DateTime? startedAt;

  const WorkoutPlanWorkoutRecordInput({
    required this.workoutPlanRecordId,
    required this.workoutRecordId,
    this.status = ProgressStatus.inProgress,
    this.week,
    this.weekDay,
    this.workoutPosition,
    this.startedAt,
  });
}
