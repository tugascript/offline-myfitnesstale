import 'package:flutter/material.dart';

import '../../../models/enums.dart';

import '../../../models/utilities.dart';

class GoalStatusBadge extends StatelessWidget {
  final ProgressStatus? status;
  final double fontSize;
  final double spacing;
  final FontWeight fontWeight;

  const GoalStatusBadge({
    super.key,
    required this.status,
    required this.fontSize,
    required this.spacing,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: spacing,
        vertical: spacing / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(),
            size: fontSize * 1.2,
            color: color,
          ),
          Text(
            " ${EnumDisplayNames.getProgressStatusDisplayName(status)}",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
          )
        ],
      ),
    );
  }

  Color _statusColor() {
    switch (status) {
      case ProgressStatus.inProgress:
        return Colors.yellow;
      case ProgressStatus.abandoned:
        return Colors.red;
      case ProgressStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon() {
    switch (status) {
      case ProgressStatus.inProgress:
        return Icons.autorenew;
      case ProgressStatus.abandoned:
        return Icons.close;
      case ProgressStatus.completed:
        return Icons.check;
      default:
        return Icons.help;
    }
  }
}
