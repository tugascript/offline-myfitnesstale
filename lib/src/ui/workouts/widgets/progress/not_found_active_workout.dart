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

import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/sizes/screen_size.dart';

class NotFoundActiveWorkout extends StatelessWidget {
  final ThemeData theme;
  final BreakPoint breakPoint;
  final DataDisplaySizesList sizes;

  const NotFoundActiveWorkout({
    super.key,
    required this.theme,
    required this.breakPoint,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = theme.brightness == Brightness.dark;
    final lightColor = isDarkTheme ? Colors.grey[600] : Colors.grey[400];
    final color = isDarkTheme ? Colors.grey[400] : Colors.grey[600];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: SizedBox(
          height: breakPoint.height / 6.75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_neutral,
                size: sizes.subtitleFontSize * 3,
                color: lightColor,
              ),
              SizedBox(height: sizes.spacing),
              Text(
                'No workout found',
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
