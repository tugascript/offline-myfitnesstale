// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:equatable/equatable.dart';

import '../../../models/sqlite/reminders_config_model.dart';
import '../../../utils/dates.dart';
import '../../core/dtos/dto.dart';

final class RemindersConfigDto extends Equatable
    implements ModelDto<RemindersConfig> {
  @override
  final int id;
  final bool workoutsOn;
  final DateTime workoutsReminderTime;
  final bool weightRecordsOn;
  final DateTime weightRecordsReminderTime;
  final bool macroTrackingOn;
  final DateTime macroTrackingReminderTime;

  const RemindersConfigDto({
    required this.id,
    required this.workoutsOn,
    required this.workoutsReminderTime,
    required this.weightRecordsOn,
    required this.weightRecordsReminderTime,
    required this.macroTrackingOn,
    required this.macroTrackingReminderTime,
  });

  factory RemindersConfigDto.fromModel(RemindersConfig model) {
    return RemindersConfigDto(
      id: model.id!,
      workoutsOn: model.workoutsOn,
      workoutsReminderTime: DateUtilities.getDateFromUnix(
        model.workoutsReminderTime,
      ),
      weightRecordsOn: model.weightRecordsOn,
      weightRecordsReminderTime: DateUtilities.getDateFromUnix(
        model.weightRecordsReminderTime,
      ),
      macroTrackingOn: model.macroTrackingOn,
      macroTrackingReminderTime: DateUtilities.getDateFromUnix(
        model.macroTrackingReminderTime,
      ),
    );
  }

  @override
  RemindersConfigDto copyWith({
    int? id,
    bool? workoutsOn,
    DateTime? workoutsReminderTime,
    bool? weightRecordsOn,
    DateTime? weightRecordsReminderTime,
    bool? macroTrackingOn,
    DateTime? macroTrackingReminderTime,
  }) {
    return RemindersConfigDto(
      id: id ?? this.id,
      workoutsOn: workoutsOn ?? this.workoutsOn,
      workoutsReminderTime: workoutsReminderTime ?? this.workoutsReminderTime,
      weightRecordsOn: weightRecordsOn ?? this.weightRecordsOn,
      weightRecordsReminderTime:
          weightRecordsReminderTime ?? this.weightRecordsReminderTime,
      macroTrackingOn: macroTrackingOn ?? this.macroTrackingOn,
      macroTrackingReminderTime:
          macroTrackingReminderTime ?? this.macroTrackingReminderTime,
    );
  }

  @override
  List<Object?> get props => [
    id,
    workoutsOn,
    workoutsReminderTime,
    weightRecordsOn,
    weightRecordsReminderTime,
    macroTrackingOn,
    macroTrackingReminderTime,
  ];
}
