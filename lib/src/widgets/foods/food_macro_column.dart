import 'package:flutter/material.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class FoodMacroColumn extends StatelessWidget {
  final String label;
  final String value;
  final DataDisplaySizesList sizes;
  final Color color;

  const FoodMacroColumn({
    super.key,
    required this.label,
    required this.value,
    required this.sizes,
    required this.color,
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
          style: TextStyle(
            fontSize: sizes.fontSize * 0.8,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
