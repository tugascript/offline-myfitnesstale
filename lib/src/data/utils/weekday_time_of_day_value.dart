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
import 'package:flutter/foundation.dart';

import 'enums.dart';
import 'time_of_day_value.dart';

/// A weekly reminder schedule: a [DayOfWeek] plus a wall-clock time.
@immutable
final class WeekdayTimeOfDayValue extends Equatable {
  static const WeekdayTimeOfDayValue defaultReminder = WeekdayTimeOfDayValue(
    dayOfWeek: DayOfWeek.monday,
    timeOfDay: TimeOfDayValue.defaultReminder,
  );

  final DayOfWeek dayOfWeek;
  final TimeOfDayValue timeOfDay;

  const WeekdayTimeOfDayValue({
    required this.dayOfWeek,
    required this.timeOfDay,
  });

  int get hour => timeOfDay.hour;

  int get minute => timeOfDay.minute;

  /// Packs weekday + minutes-since-midnight into a single integer.
  ///
  /// Layout: `(dayOfWeek.value - 1) * minutesPerDay + minutesSinceMidnight`.
  int get packedValue =>
      (dayOfWeek.value - 1) * TimeOfDayValue.minutesPerDay +
      timeOfDay.minutesSinceMidnight;

  factory WeekdayTimeOfDayValue.fromPackedValue(int packed) {
    final minutesPerDay = TimeOfDayValue.minutesPerDay;
    final normalized = packed % (7 * minutesPerDay);
    final positive = normalized < 0
        ? normalized + 7 * minutesPerDay
        : normalized;
    final dayIndex = positive ~/ minutesPerDay;
    final minutes = positive % minutesPerDay;
    return WeekdayTimeOfDayValue(
      dayOfWeek: DayOfWeek.fromValue(dayIndex + 1),
      timeOfDay: TimeOfDayValue.fromMinutesSinceMidnight(minutes),
    );
  }

  factory WeekdayTimeOfDayValue.fromDateTime(DateTime dateTime) {
    return WeekdayTimeOfDayValue(
      dayOfWeek: DayOfWeek.fromDateTime(dateTime),
      timeOfDay: TimeOfDayValue.fromDateTime(dateTime),
    );
  }

  WeekdayTimeOfDayValue copyWith({
    DayOfWeek? dayOfWeek,
    TimeOfDayValue? timeOfDay,
  }) {
    return WeekdayTimeOfDayValue(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      timeOfDay: timeOfDay ?? this.timeOfDay,
    );
  }

  @override
  List<Object?> get props => [dayOfWeek, timeOfDay];

  @override
  String toString() => '${dayOfWeek.name} $timeOfDay';
}
