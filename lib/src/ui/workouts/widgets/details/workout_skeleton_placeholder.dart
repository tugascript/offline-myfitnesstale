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

import '../../../core/sizes/data_display_sizes.dart';

class WorkoutSkeletonPlaceholder extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final String sectionTitle;
  final Widget? header;

  const WorkoutSkeletonPlaceholder({
    super.key,
    required this.theme,
    required this.sizes,
    required this.sectionTitle,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(sizes.viewPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header ??
              Card(
                margin: EdgeInsets.zero,
                shape: const BeveledRectangleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(sizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loading Workout Name',
                        style: TextStyle(
                          fontSize: sizes.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: sizes.halfSpacing),
                      Text(
                        'Loading workout description placeholder...',
                        style: TextStyle(fontSize: sizes.fontSize),
                      ),
                      SizedBox(height: sizes.halfSpacing),
                      Text(
                        'Loading workout summary',
                        style: TextStyle(fontSize: sizes.smallFontSize),
                      ),
                    ],
                  ),
                ),
              ),
          SizedBox(height: sizes.betweenSpacing),
          Text(
            sectionTitle,
            style: TextStyle(
              fontSize: sizes.titleFontSize,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.grey[200] : Colors.grey[800],
            ),
          ),
          SizedBox(height: sizes.spacing),
          for (int i = 0; i < 2; i++) ...[
            Card(
              margin: EdgeInsets.zero,
              shape: const BeveledRectangleBorder(),
              child: Padding(
                padding: EdgeInsets.all(sizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading Set Placeholder',
                      style: TextStyle(
                        fontSize: sizes.subtitleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: sizes.halfSpacing),
                    Text(
                      'Loading exercise details placeholder...',
                      style: TextStyle(fontSize: sizes.fontSize),
                    ),
                  ],
                ),
              ),
            ),
            if (i == 0) SizedBox(height: sizes.spacing),
          ],
          SizedBox(height: sizes.spacing),
        ],
      ),
    );
  }
}
