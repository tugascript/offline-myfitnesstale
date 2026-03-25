import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import '../../../utilities/sizes/screen_size.dart';

class NotFoundActiveWorkout extends StatelessWidget {
  final ThemeData theme;
  final BreakPoint breakPoint;
  final DataDisplaySizesList sizes;

  const NotFoundActiveWorkout({
    super.key,
    required this.theme,
    required this.breakPoint,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = theme.brightness == Brightness.dark;
    final lightColor = isDarkTheme ? Colors.grey[600] : Colors.grey[400];
    final color = isDarkTheme ? Colors.grey[400] : Colors.grey[600];

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
                Icons.sentiment_neutral,
                size: sizes.subtitleFontSize * 3,
                color: lightColor,
              ),
              SizedBox(height: sizes.spacing),
              Text(
                'No workout found',
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
