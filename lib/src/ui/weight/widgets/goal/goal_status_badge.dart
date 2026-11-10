// Copyright (C) 2026 afonsobarracha
// 
// This file is part of My Fitness Tale.
// 
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

import '../../../../data/utils/enums.dart';
import '../../../../data/utils/display_names.dart';

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
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing / 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(), size: fontSize * 1.2, color: color),
          Text(
            " ${EnumDisplayNames.getProgressStatusDisplayName(status)}",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
          ),
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
