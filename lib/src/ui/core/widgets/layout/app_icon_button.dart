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

class AppIconButton extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final Color color;
  final IconData icon;
  final String tooltip;
  final void Function()? onPressed;
  final bool small;

  const AppIconButton({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.color,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greyedOut = ThemedColors.themedGrey.fromBrightness(theme.brightness);
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        color: isLoading ? greyedOut : color,
        size: small ? sizes.btnMediumIconSize : sizes.mediumIconSize,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
