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
import '../../../utils/time_of_day_value.dart';
import '../../../utils/weekday_time_of_day_value.dart';
import '../../core/inputs/input.dart';

final class RemindersConfigInput extends Equatable
    implements ModelInput<RemindersConfig> {
  final bool workoutsOn;
  final TimeOfDayValue workoutsReminderTime;
  final bool weightRecordsOn;
  final WeekdayTimeOfDayValue weightRecordsReminderTime;
  final bool macroTrackingOn;
  final TimeOfDayValue macroTrackingReminderTime;

  const RemindersConfigInput({
    required this.workoutsOn,
    required this.workoutsReminderTime,
    required this.weightRecordsOn,
    required this.weightRecordsReminderTime,
    required this.macroTrackingOn,
    required this.macroTrackingReminderTime,
  });

  /// Default reminder clock times when the UI has not chosen specific ones.
  factory RemindersConfigInput.withDefaultTimes({
    required bool workoutsOn,
    required bool weightRecordsOn,
    required bool macroTrackingOn,
  }) {
    return RemindersConfigInput(
      workoutsOn: workoutsOn,
      workoutsReminderTime: TimeOfDayValue.defaultReminder,
      weightRecordsOn: weightRecordsOn,
      weightRecordsReminderTime: WeekdayTimeOfDayValue.defaultReminder,
      macroTrackingOn: macroTrackingOn,
      macroTrackingReminderTime: TimeOfDayValue(hour: 20, minute: 0),
    );
  }

  @override
  List<Object?> get props => [
    workoutsOn,
    workoutsReminderTime,
    weightRecordsOn,
    weightRecordsReminderTime,
    macroTrackingOn,
    macroTrackingReminderTime,
  ];
}
