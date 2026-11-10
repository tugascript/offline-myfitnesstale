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

import '../../core/sizes/data_display_sizes.dart';
import './quick_action_category.dart';

class QuickActionDestinationSheet extends StatelessWidget {
  final QuickActionCategory category;
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const QuickActionDestinationSheet({
    super.key,
    required this.category,
    required this.sizes,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.padding,
        0,
        sizes.padding,
        sizes.padding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.title,
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('quick-action-sheet-close'),
                tooltip: 'Close menu',
                icon: Icon(Icons.close, size: sizes.buttonIconSize),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          SizedBox(height: sizes.spacing / 2),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final destination in category.destinations)
                    ListTile(
                      key: ValueKey('quick-action-${destination.id}'),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: sizes.padding,
                        vertical: sizes.spacing / 2,
                      ),
                      leading: Icon(
                        destination.icon,
                        size: sizes.buttonIconSize,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        destination.label,
                        style: TextStyle(fontSize: sizes.fontSize),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        size: sizes.buttonIconSize,
                      ),
                      onTap: () => Navigator.of(context).pop(destination.route),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
