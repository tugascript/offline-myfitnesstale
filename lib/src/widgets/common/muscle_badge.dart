import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/utilities.dart';

class MuscleBadge extends StatelessWidget {
  final Muscle muscle;
  final double fontSize;
  final ThemeData theme;

  const MuscleBadge({
    super.key,
    required this.muscle,
    required this.fontSize,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      shape: BeveledRectangleBorder(),
      side: BorderSide.none,
      backgroundColor: theme.colorScheme.secondary.withValues(
        alpha: 0.2,
      ),
      visualDensity: VisualDensity.compact,
      label: Text(
        EnumDisplayNames.getMuscleDisplayName(muscle),
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
    );
  }
}
