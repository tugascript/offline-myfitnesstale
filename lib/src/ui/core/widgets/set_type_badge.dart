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

import '../../../data/utils/enums.dart';

import '../sizes/data_display_sizes.dart';
import '../../../data/utils/display_names.dart';

class SetTypeBadge extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final WorkoutSetType setType;

  const SetTypeBadge({super.key, required this.sizes, required this.setType});

  Color _getSetTypeColor(WorkoutSetType type) {
    switch (type) {
      case WorkoutSetType.standard:
        return Colors.blue;
      case WorkoutSetType.drop:
        return Colors.red;
      case WorkoutSetType.superSet:
        return Colors.purple;
      case WorkoutSetType.giant:
        return Colors.green;
      case WorkoutSetType.pyramid:
        return Colors.amber;
      case WorkoutSetType.circuit:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSetTypeColor(setType);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.padding / 4,
        vertical: sizes.padding / 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        EnumDisplayNames.getSetTypeDisplayName(setType),
        style: TextStyle(color: color, fontSize: sizes.smallFontSize),
      ),
    );
  }
}
