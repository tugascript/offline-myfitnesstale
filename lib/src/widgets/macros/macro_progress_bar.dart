import 'package:flutter/material.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class MacroProgressBar extends StatelessWidget {
  final String label;
  final int current;
  final int target;
  final String unit;
  final Color color;
  final DataDisplaySizesList sizes;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: sizes.fontSize * 0.8,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          '$current/$target$unit',
          style: TextStyle(
            fontSize: sizes.fontSize * 0.75,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: sizes.spacing / 2),
        LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
