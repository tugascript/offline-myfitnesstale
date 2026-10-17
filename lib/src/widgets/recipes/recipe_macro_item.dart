import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';

class RecipeMacroItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final DataDisplaySizesList sizes;

  const RecipeMacroItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: sizes.spacing / 2),
        Text(
          label,
          style: TextStyle(fontSize: sizes.fontSize * 0.8, color: Colors.grey),
        ),
      ],
    );
  }
}
