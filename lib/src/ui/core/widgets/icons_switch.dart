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

import './layout/sharp_switch.dart';

class IconsSwitch extends StatelessWidget {
  final ThemeData theme;
  final IconData offIcon;
  final IconData onIcon;
  final bool switchOn;
  final double iconSize;
  final double spacing;
  final double switchPadding;
  final double thumbSize;
  final ValueChanged<bool> onChanged;

  const IconsSwitch({
    super.key,
    required this.theme,
    required this.offIcon,
    required this.onIcon,
    required this.switchOn,
    required this.spacing,
    required this.switchPadding,
    required this.thumbSize,
    required this.iconSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => onChanged(false),
          child: Icon(
            offIcon,
            size: iconSize,
            color: switchOn
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: spacing),
        SharpSwitch(
          value: switchOn,
          onChanged: onChanged,
          thumbSize: thumbSize,
          padding: EdgeInsets.all(switchPadding),
        ),
        SizedBox(width: spacing),
        InkWell(
          onTap: () => onChanged(true),
          child: Icon(
            onIcon,
            size: iconSize,
            color: switchOn
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
