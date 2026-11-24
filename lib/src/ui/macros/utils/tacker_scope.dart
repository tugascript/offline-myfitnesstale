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

import 'package:material_ui/material_ui.dart';

enum TrackerScope { day, week, month }

extension TrackerScopeDates on TrackerScope {
  bool canGoPrevious(DateTime selectedDate, DateTime minDate) {
    final selected = DateUtils.dateOnly(selectedDate);
    final DateTime previousPeriodEnd;
    switch (this) {
      case TrackerScope.day:
        previousPeriodEnd = DateTime(
          selected.year,
          selected.month,
          selected.day - 1,
        );
      case TrackerScope.week:
        final weekStart = _startOfWeek(selected);
        previousPeriodEnd = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day - 1,
        );
      case TrackerScope.month:
        previousPeriodEnd = DateTime(selected.year, selected.month, 0);
    }
    return !previousPeriodEnd.isBefore(minDate);
  }

  bool canGoNext(DateTime selectedDate, DateTime today) {
    final selected = DateUtils.dateOnly(selectedDate);
    final DateTime nextPeriodStart;
    switch (this) {
      case TrackerScope.day:
        nextPeriodStart = DateTime(
          selected.year,
          selected.month,
          selected.day + 1,
        );
      case TrackerScope.week:
        final weekStart = _startOfWeek(selected);
        nextPeriodStart = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day + 7,
        );
      case TrackerScope.month:
        nextPeriodStart = DateTime(selected.year, selected.month + 1, 1);
    }
    return !nextPeriodStart.isAfter(today);
  }

  DateTime previousDate(DateTime selectedDate, DateTime minDate) {
    final DateTime prev;
    switch (this) {
      case TrackerScope.day:
        prev = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day - 1,
        );
      case TrackerScope.week:
        prev = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day - 7,
        );
      case TrackerScope.month:
        prev = DateTime(selectedDate.year, selectedDate.month - 1, 1);
    }
    return prev.isBefore(minDate) ? minDate : prev;
  }

  DateTime nextDate(DateTime selectedDate, DateTime minDate, DateTime today) {
    final DateTime next;
    switch (this) {
      case TrackerScope.day:
        next = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day + 1,
        );
      case TrackerScope.week:
        next = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day + 7,
        );
      case TrackerScope.month:
        next = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    }
    if (next.isAfter(today)) return today;
    return next.isBefore(minDate) ? minDate : next;
  }

  ({DateTime start, DateTime end}) rangeBounds(DateTime selectedDate) {
    switch (this) {
      case TrackerScope.day:
        final day = DateUtils.dateOnly(selectedDate);
        return (start: day, end: day);
      case TrackerScope.week:
        final start = _startOfWeek(selectedDate);
        final end = DateTime(start.year, start.month, start.day + 6);
        return (start: start, end: end);
      case TrackerScope.month:
        final start = DateTime(selectedDate.year, selectedDate.month, 1);
        final end = DateTime(selectedDate.year, selectedDate.month + 1, 0);
        return (start: start, end: end);
    }
  }

  static DateTime _startOfWeek(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));
}
