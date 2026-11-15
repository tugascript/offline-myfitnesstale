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

import '../../../core/sizes/data_display_sizes.dart';

class AppSettingsSelector<T> extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final T value;
  final List<T> values;
  final String label;
  final Color titleColor;
  final Function(T?) onChanged;
  final IconData Function(T) getIcon;
  final Color? iconColor;
  final String Function(T) getText;

  const AppSettingsSelector({
    super.key,
    required this.sizes,
    required this.value,
    required this.values,
    required this.label,
    required this.titleColor,
    required this.onChanged,
    required this.getIcon,
    this.iconColor,
    required this.getText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: sizes.profileLabelWidth,
          child: Text(
            label,
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ),
        Expanded(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            isDense: true,
            underline: Container(),
            items: values.map((T v) {
              return DropdownMenuItem<T>(
                value: v,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getIcon(v),
                      size: sizes.iconSubtitleFontSize,
                      color: iconColor,
                    ),
                    SizedBox(width: sizes.spacing),
                    Text(
                      getText(v),
                      style: TextStyle(fontSize: sizes.subtitleFontSize),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
