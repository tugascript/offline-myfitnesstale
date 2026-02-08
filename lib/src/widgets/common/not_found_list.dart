import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';

class NotFoundList extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final String name;

  const NotFoundList({
    super.key,
    required this.sizes,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final lightColor = isDarkTheme ? Colors.grey[600] : Colors.grey[400];
    final color = isDarkTheme ? Colors.grey[400] : Colors.grey[600];

    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: sizes.margins),
            Icon(
              Icons.sentiment_neutral,
              size: sizes.titleFountSize * 3,
              color: lightColor,
            ),
            SizedBox(height: sizes.margins),
            Text(
              'No $name found',
              style: TextStyle(
                fontSize: sizes.titleFountSize,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
