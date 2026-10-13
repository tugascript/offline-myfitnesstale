import 'package:flutter/material.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class MacroGoalChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final DataDisplaySizesList sizes;

  const MacroGoalChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: sizes.padding / 2, horizontal: sizes.padding / 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: sizes.fontSize * 0.8,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: sizes.spacing / 2),
          Text(
            value,
            style: TextStyle(
              fontSize: sizes.subtitleFontSize * 0.9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
