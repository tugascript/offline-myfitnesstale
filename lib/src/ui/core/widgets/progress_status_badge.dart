// Copyright (C) 2026 Afonso Barracha
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

import 'package:material_ui/material_ui.dart';

import '../../../data/utils/enums.dart';
import '../sizes/data_display_sizes.dart';
import '../utils/progress_status_presentation.dart';

class ProgressStatusBadge extends StatelessWidget {
  final ProgressStatus status;
  final DataDisplaySizesList sizes;
  final double? fontSize;
  final FontWeight fontWeight;

  const ProgressStatusBadge({
    super.key,
    required this.status,
    required this.sizes,
    this.fontSize,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFontSize = fontSize ?? sizes.smallFontSize;
    final presentation = ProgressStatusPresentation.fromStatus(
      status,
      Theme.of(context).brightness,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.halfSpacing,
        vertical: sizes.quarterSpacing,
      ),
      decoration: BoxDecoration(
        color: presentation.color.withValues(alpha: 0.2),
        border: Border.all(color: presentation.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            presentation.icon,
            size: effectiveFontSize * 1.15,
            color: presentation.color,
          ),
          SizedBox(width: sizes.quarterSpacing),
          Flexible(
            child: Text(
              presentation.label,
              style: TextStyle(
                fontSize: effectiveFontSize,
                fontWeight: fontWeight,
                color: presentation.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
