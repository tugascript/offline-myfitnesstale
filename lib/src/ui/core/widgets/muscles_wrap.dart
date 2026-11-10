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

import '../../../data/utils/enums.dart';
import '../sizes/data_display_sizes.dart';
import './muscle_badge.dart';

class MusclesWrap extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  final Widget? leading;
  final String title;
  final Set<Muscle> muscles;

  const MusclesWrap({
    super.key,
    required this.theme,
    required this.sizes,
    this.leading,
    required this.title,
    required this.muscles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ?leading,
            Flexible(
              child: Text(
                leading != null ? " $title" : title,
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.spacing / 2),
        Wrap(
          spacing: sizes.spacing / 4,
          runSpacing: sizes.spacing / 4,
          children: muscles.map((m) {
            return MuscleBadge(
              muscle: m,
              fontSize: sizes.smallFontSize,
              theme: theme,
            );
          }).toList(),
        ),
      ],
    );
  }
}
