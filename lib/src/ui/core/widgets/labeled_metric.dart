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

class LabeledMetric extends StatelessWidget {
  final ThemeData theme;
  final Widget leading;
  final String label;
  final String value;
  final double fontSize;

  const LabeledMetric({
    super.key,
    required this.theme,
    required this.leading,
    required this.label,
    required this.value,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = theme.brightness == Brightness.dark;
    final labelColor = isDarkTheme ? Colors.grey[400] : Colors.grey[600];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        SizedBox(width: fontSize / 4),
        Flexible(
          child: Text.rich(
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontSize: fontSize,
                color: labelColor,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
