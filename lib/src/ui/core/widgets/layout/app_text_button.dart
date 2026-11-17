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
import '../../themes/colors.dart';

class AppTextButton extends StatelessWidget {
  final bool isLoading;
  final DataDisplaySizesList sizes;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isDense;

  const AppTextButton({
    super.key,
    required this.isLoading,
    required this.sizes,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isDense = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = isSecondary
        ? theme.colorScheme.secondary
        : theme.primaryColor;
    final greyColor = ThemedColors.themedGrey.fromBrightness(
      theme.colorScheme.brightness,
    );
    final color = isLoading ? greyColor : baseColor;
    return TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(
        icon,
        size: sizes.btnIconSize,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      label: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: sizes.subtitleFontSize,
          fontWeight: FontWeight.w500,
          color: color,
        ),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: sizes.halfPadding),
        shape: BeveledRectangleBorder(),
        visualDensity: isDense ? VisualDensity.compact : VisualDensity.standard,
      ),
    );
  }
}
