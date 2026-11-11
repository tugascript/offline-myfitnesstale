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

import './sharp_switch.dart';

class SharpSwitchTitle extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry? switchPadding;
  final double? thumbSize;

  const SharpSwitchTitle({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.contentPadding,
    this.switchPadding,
    this.titleStyle,
    this.thumbSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      child: Padding(
        padding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: titleStyle ?? Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            SharpSwitch(
              value: value,
              onChanged: onChanged,
              enabled: enabled,
              padding: switchPadding,
              thumbSize: thumbSize ?? 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
