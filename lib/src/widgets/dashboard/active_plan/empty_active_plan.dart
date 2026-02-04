import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utilities/sizes/home_sizes.dart';

class EmptyActivePlan extends StatelessWidget {
  final HomeSizesList sizes;

  const EmptyActivePlan({
    super.key,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final spacing = sizes.breaks / 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Workout Plan',
          style: TextStyle(
            fontSize: sizes.sectionTitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.breaks / 3),
        Card(
          color: theme.scaffoldBackgroundColor,
          child: SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () {
                context.push('/workout-plans');
              },
              child: Padding(
                padding: EdgeInsets.all(sizes.padding),
                child: Column(
                  children: [
                    Icon(
                      Icons.snooze,
                      size: sizes.subtitleFontSize * 2,
                    ),
                    SizedBox(height: spacing),
                    Text(
                      'No Active Workout Plan',
                      style: TextStyle(
                        fontSize: sizes.subtitleFontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkTheme ? Colors.grey[200] : Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      'Start an old or create a new workout plan',
                      style: TextStyle(
                        fontSize: sizes.fontSize,
                        color:
                            isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
