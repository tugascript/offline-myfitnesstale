import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';

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
        icon: Text(
          '🏋️',
          style: TextStyle(
            fontSize: sizes.fontSize * 1.2,
          ),
        ),
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
