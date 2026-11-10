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

import 'package:flutter/material.dart';

import '../sizes/data_display_sizes.dart';

class MutationButton extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color? color;
  final String label;
  final IconData icon;
  final bool isDense;

  const MutationButton({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.onPressed,
    this.color,
    this.label = 'EDIT',
    this.icon = Icons.edit,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    final lightGrey = theme.brightness == Brightness.light
        ? Colors.grey[400]
        : Colors.grey[600];
    final baseColor = (color ?? theme.colorScheme.primary);
    final btnColor = isLoading ? lightGrey! : baseColor;
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon, size: sizes.fontSize, fontWeight: FontWeight.w600),
      label: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: sizes.subtitleFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: sizes.padding),
        visualDensity: isDense ? VisualDensity.compact : VisualDensity.standard,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: btnColor,
        side: BorderSide(color: btnColor, width: 1),
        shape: const BeveledRectangleBorder(),
      ),
    );
  }
}
