import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import '../../../utilities/sizes/screen_size.dart';

class ActiveCompletedWorkout extends StatelessWidget {
  final BreakPoint breakPoint;
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const ActiveCompletedWorkout({
    super.key,
    required this.breakPoint,
    required this.sizes,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: SizedBox(
          height: breakPoint.height / 6.75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.celebration,
                size: sizes.subtitleFontSize * 2,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: sizes.spacing),
              Text(
                "Workout completed!",
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
