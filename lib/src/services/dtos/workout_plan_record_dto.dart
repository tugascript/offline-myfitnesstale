import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/workout_plan_record_model.dart';
import 'dto.dart';

class WorkoutPlanRecordDto extends Equatable implements Dto<WorkoutPlanRecord> {
  @override
  final int id;
  final int workoutPlanId;
  final int workoutPlanVersion;
  final ProgressStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const WorkoutPlanRecordDto({
    required this.id,
    required this.workoutPlanId,
    required this.workoutPlanVersion,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  @override
  factory WorkoutPlanRecordDto.fromModel(WorkoutPlanRecord model) {
    return WorkoutPlanRecordDto(
      id: model.id!,
      workoutPlanId: model.workoutPlanId,
      workoutPlanVersion: model.workoutPlanVersion,
      status: model.status,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        model.createdAt * 1000,
        isUtc: true,
      ),
      completedAt: model.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              model.completedAt! * 1000,
              isUtc: true,
            )
          : null,
    );
  }

  @override
  WorkoutPlanRecordDto copyWith({
    int? id,
    int? workoutPlanId,
    int? workoutPlanVersion,
    ProgressStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return WorkoutPlanRecordDto(
      id: id ?? this.id,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      workoutPlanVersion: workoutPlanVersion ?? this.workoutPlanVersion,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutPlanId,
        workoutPlanVersion,
        status,
        completedAt,
      ];
}
