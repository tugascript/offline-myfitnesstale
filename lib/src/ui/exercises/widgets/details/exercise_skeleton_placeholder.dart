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

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/base_details_header.dart';
import '../../../core/widgets/difficulty_badge.dart';

class ExerciseSkeletonPlaceholder extends StatelessWidget {
  final DataDisplaySizesList sizes;

  const ExerciseSkeletonPlaceholder({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(sizes.viewPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BaseDetailsHeader(
            padding: sizes.padding,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DifficultyBadge(
                      spacing: sizes.spacing,
                      difficulty: Difficulty.beginner,
                      fontSize: sizes.smallFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: null,
                  ),
                ],
              ),
              SizedBox(height: sizes.spacing),
              Text(
                'Loading Exercise Summary',
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
              SizedBox(height: sizes.spacing),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: sizes.halfSpacing),
              Text(
                'Loading exercise description placeholder...',
                style: TextStyle(fontSize: sizes.fontSize),
              ),
            ],
          ),
          SizedBox(height: sizes.doubleSpacing),
        ],
      ),
    );
  }
}
