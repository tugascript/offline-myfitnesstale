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

import '../../../data/utils/enums.dart';
import '../../core/utils/formatters.dart';

class RelativeDateLabel extends StatelessWidget {
  final Units units;
  final DateTime date;
  final double fontSize;
  final String? prefix;
  final FontWeight fontWeight;
  final Color? color;

  const RelativeDateLabel({
    super.key,
    required this.units,
    required this.date,
    required this.fontSize,
    this.prefix,
    this.fontWeight = FontWeight.w400,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final label = prefix == null
        ? ' ${Formatters.formatRelativeDate(units, date)}'
        : ' $prefix${Formatters.formatRelativeDate(units, date)}';

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: fontSize * 1.15, color: color),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
