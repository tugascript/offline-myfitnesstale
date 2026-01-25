import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/workout_plan_record_model.dart';
import 'dto.dart';

class WorkoutPlanRecordDto extends Equatable implements Dto<WorkoutPlanRecord> {
  @override
  final int id;
  final int workoutPlanId;
  final ProgressStatus status;
  final DateTime? completedAt;

  const WorkoutPlanRecordDto({
    required this.id,
    required this.workoutPlanId,
    required this.status,
    this.completedAt,
  });

  @override
  factory WorkoutPlanRecordDto.fromModel(WorkoutPlanRecord model) {
    return WorkoutPlanRecordDto(
      id: model.id!,
      workoutPlanId: model.workoutPlanId,
      status: model.status,
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(model.completedAt! * 1000,
              isUtc: true)
          : null,
    );
  }

  @override
  WorkoutPlanRecordDto copyWith({
    int? id,
    int? workoutPlanId,
    ProgressStatus? status,
    DateTime? completedAt,
  }) {
    return WorkoutPlanRecordDto(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanId,
        status,
        completedAt,
      ];
}
