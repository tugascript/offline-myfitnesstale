import 'package:flutter/material.dart';

class TotalString extends StatelessWidget {
  final String name;
  final Widget? leading;
  final String total;
  final double fontSize;

  const TotalString({
    super.key,
    required this.name,
    this.leading,
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
        if (leading != null) ...[leading!, const SizedBox(width: 4)],
        Flexible(
          child: Text.rich(
            TextSpan(
              text: "Total $name: ",
              style: TextStyle(
                fontSize: fontSize,
                color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: total,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
