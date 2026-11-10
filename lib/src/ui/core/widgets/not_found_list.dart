// Copyright (C) 2026 afonsobarracha
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

import '../sizes/data_display_sizes.dart';

class NotFoundList extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final String? name;
  final String? message;
  final double? height;
  final IconData? icon;

  const NotFoundList({
    super.key,
    required this.sizes,
    this.message,
    this.name,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final lightColor = isDarkTheme ? Colors.grey[600] : Colors.grey[400];
    final color = isDarkTheme ? Colors.grey[400] : Colors.grey[600];

    return SizedBox(
      height: height ?? MediaQuery.of(context).size.height / 2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: sizes.margins),
            Icon(
              icon ?? Icons.sentiment_neutral,
              size: sizes.titleFontSize * 3,
              color: lightColor,
            ),
            SizedBox(height: sizes.margins),
            Text(
              message ?? 'No ${name ?? 'data'} found',
              style: TextStyle(fontSize: sizes.titleFontSize, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
