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

import '../../core/sizes/data_display_sizes.dart';
import '../../core/themes/colors.dart';
import './quick_action_category.dart';

class QuickActionCategoryCard extends StatelessWidget {
  final QuickActionCategory category;
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final VoidCallback onTap;

  const QuickActionCategoryCard({
    super.key,
    required this.category,
    required this.sizes,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = theme.colorScheme.brightness == Brightness.light
        ? kPrimaryOrangeSwatch.shade600
        : theme.colorScheme.primary;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: BeveledRectangleBorder(side: BorderSide(color: color, width: 1)),
      child: InkWell(
        onTap: onTap,
        overlayColor: WidgetStatePropertyAll(color.withValues(alpha: 0.2)),
        child: Padding(
          padding: EdgeInsets.all(sizes.padding),
          child: Column(
            children: [
              Icon(category.icon, size: sizes.mediumIconSize, color: color),
              SizedBox(height: sizes.spacing / 2),
              Text(
                category.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              SizedBox(height: sizes.spacing / 6),
              Text(
                category.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: sizes.fontSize, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
