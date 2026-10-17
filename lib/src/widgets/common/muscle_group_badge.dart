import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/utilities.dart';

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
