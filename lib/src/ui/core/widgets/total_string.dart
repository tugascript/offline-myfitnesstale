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

class TotalString extends StatelessWidget {
  final String name;
  final Widget? leading;
  final String total;
  final double fontSize;

  const TotalString({
    super.key,
    required this.name,
    this.leading,
    required this.total,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, SizedBox(width: fontSize / 4)],
        Flexible(
          child: Text.rich(
            TextSpan(
              text: "Total $name: ",
              style: TextStyle(
                fontSize: fontSize,
                color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: total,
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
