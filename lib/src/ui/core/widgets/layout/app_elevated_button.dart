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

import '../../sizes/data_display_sizes.dart';

class AppElevatedButton extends StatelessWidget {
  final ThemeData theme;
  final bool isLoading;
  final DataDisplaySizesList sizes;
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final bool isDense;
  final bool isSecondary;

  const AppElevatedButton({
    super.key,
    required this.theme,
    required this.isLoading,
    required this.sizes,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.isDense = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isSecondary
        ? theme.colorScheme.secondary
        : theme.primaryColor;
    final greyColor = theme.colorScheme.brightness == Brightness.light
        ? Colors.grey[400]
        : Colors.grey[600];
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon, size: sizes.fontSize * 1.2, fontWeight: FontWeight.w600),
      label: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: sizes.subtitleFontSize,
          fontWeight: FontWeight.w600,
        ),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: sizes.padding),
        backgroundColor: isLoading ? greyColor : baseColor,
        foregroundColor: theme.scaffoldBackgroundColor,
        shape: BeveledRectangleBorder(),
        visualDensity: isDense ? VisualDensity.compact : VisualDensity.standard,
      ),
    );
  }
}
