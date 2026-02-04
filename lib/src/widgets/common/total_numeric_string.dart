import 'package:flutter/material.dart';

class TotalNumericString extends StatelessWidget {
  final String name;
  final String? emoji;
  final int total;
  final double fontSize;

  const TotalNumericString({
    super.key,
    required this.name,
    this.emoji,
    required this.total,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...(emoji != null && emoji!.isNotEmpty
            ? [
                Text(
                  "$emoji ",
                  style: TextStyle(fontSize: fontSize * 1.2),
                )
              ]
            : []),
        Text(
          "Total $name: ",
          style: TextStyle(
            fontSize: fontSize,
            color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          total.toString(),
          style: TextStyle(
            fontSize: fontSize,
            color: theme.colorScheme.onSurface,
          ),
        )
      ],
    );
  }
}
