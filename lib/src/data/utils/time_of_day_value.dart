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

/// A wall-clock time within a single 24-hour day (no date component).
@immutable
final class TimeOfDayValue extends Equatable {
  static const int minutesPerDay = 24 * 60;
  static const TimeOfDayValue defaultReminder = TimeOfDayValue(
    hour: 8,
    minute: 0,
  );

  final int hour;
  final int minute;

  const TimeOfDayValue({required this.hour, required this.minute})
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  int get minutesSinceMidnight => hour * 60 + minute;

  factory TimeOfDayValue.fromMinutesSinceMidnight(int minutes) {
    final normalized = minutes % minutesPerDay;
    final positive = normalized < 0 ? normalized + minutesPerDay : normalized;
    return TimeOfDayValue(hour: positive ~/ 60, minute: positive % 60);
  }

  factory TimeOfDayValue.fromDateTime(DateTime dateTime) {
    return TimeOfDayValue(hour: dateTime.hour, minute: dateTime.minute);
  }

  @override
  List<Object?> get props => [hour, minute];

  @override
  String toString() {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
