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

import 'package:flutter/material.dart';

import '../../../../data/utils/enums.dart';

class GoalDate extends StatelessWidget {
  final Units units;
  final DateTime? date;
  final double fontSize;
  final IconData icon;

  const GoalDate({
    super.key,
    required this.icon,
    required this.units,
    required this.date,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: fontSize * 1.2),
        SizedBox(width: fontSize / 2),
        Text(
          " ${_displayDate(units, date)}",
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _displayDate(Units units, DateTime? date) {
    if (date == null) {
      return 'Unknown';
    }

    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    final calendarDate = units == Units.imperial
        ? '$month/$day/$year'
        : '$day/$month/$year';
    return '$calendarDate $hour:$minute';
  }
}
