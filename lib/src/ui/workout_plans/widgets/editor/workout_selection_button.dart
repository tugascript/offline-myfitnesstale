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

import '../../../core/sizes/data_display_sizes.dart';

class WorkoutSelectionButton extends StatelessWidget {
  final String? workoutName;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final VoidCallback onPressed;

  const WorkoutSelectionButton({
    super.key,
    required this.workoutName,
    required this.sizes,
    required this.theme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sizes.fontSize * 3,
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Text('🏋️', style: TextStyle(fontSize: sizes.fontSize * 1.2)),
        label: Text(
          workoutName == null ? "Select Workout" : workoutName!,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary, width: 0.5),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
