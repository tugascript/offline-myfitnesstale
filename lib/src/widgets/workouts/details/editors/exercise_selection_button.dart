import 'package:flutter/material.dart';

import '../../../../utilities/sizes/data_display_sizes.dart';

class ExerciseSelectionButton extends StatelessWidget {
  final String? exerciseName;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final VoidCallback onPressed;

  const ExerciseSelectionButton({
    super.key,
    required this.exerciseName,
    required this.sizes,
    required this.theme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sizes.fontSize * 3,
      child: OutlinedButton.icon(
        icon: Icon(Icons.fitness_center, size: sizes.fontSize * 1.2),
        label: Text(
          exerciseName == null ? "Select Exercise" : exerciseName!,
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
          side: BorderSide(
            color: theme.colorScheme.primary,
            width: 0.5,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
