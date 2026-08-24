import 'package:equatable/equatable.dart';

import '../../models/reminders_config_model.dart';
import 'dto.dart';

class RemindersConfigDto extends Equatable implements Dto<RemindersConfig> {
  @override
  final int id;
  final bool workoutsOn;
  final bool weightRecordsOn;

  const RemindersConfigDto({
    required this.id,
    required this.workoutsOn,
    required this.weightRecordsOn,
  });

  factory RemindersConfigDto.fromModel(RemindersConfig model) {
    return RemindersConfigDto(
      id: model.id!,
      workoutsOn: model.workoutsOn,
      weightRecordsOn: model.weightRecordsOn,
    );
  }

  @override
  RemindersConfigDto copyWith({
    int? id,
    bool? workoutsOn,
    bool? weightRecordsOn,
  }) {
    return RemindersConfigDto(
      id: id ?? this.id,
      workoutsOn: workoutsOn ?? this.workoutsOn,
      weightRecordsOn: weightRecordsOn ?? this.weightRecordsOn,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutsOn,
        weightRecordsOn,
      ];
}
