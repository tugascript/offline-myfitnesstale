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
import '../../../data/utils/display_names.dart';

class MuscleGroupBadge extends StatelessWidget {
  final MuscleGroup muscleGroup;
  final double fontSize;
  final ThemeData theme;

  const MuscleGroupBadge({
    super.key,
    required this.muscleGroup,
    required this.fontSize,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      shape: BeveledRectangleBorder(),
      side: BorderSide.none,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      visualDensity: VisualDensity.compact,
      label: Text(
        EnumDisplayNames.getMuscleGroupDisplayName(muscleGroup),
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}
