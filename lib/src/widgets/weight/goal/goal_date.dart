import 'package:flutter/material.dart';

import '../../../models/enums.dart';

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
        Icon(
          icon,
          size: fontSize * 1.2,
        ),
        SizedBox(width: fontSize / 2),
        Text(
          " ${_displayDate(units, date)}",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
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

    final calendarDate =
        units == Units.imperial ? '$month/$day/$year' : '$day/$month/$year';
    return '$calendarDate $hour:$minute';
  }
}
