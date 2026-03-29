import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/utilities.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class SetTypeBadge extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final WorkoutSetType setType;

  const SetTypeBadge({
    super.key,
    required this.sizes,
    required this.setType,
  });

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
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        EnumDisplayNames.getSetTypeDisplayName(setType),
        style: TextStyle(
          color: color,
          fontSize: sizes.smallFontSize,
        ),
      ),
    );
  }
}
