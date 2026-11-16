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

class TitledSection extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final String title;
  final Widget child;
  final IconData? icon;

  const TitledSection({
    super.key,
    required this.sizes,
    required this.title,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Row(
            children: [
              Icon(icon, size: sizes.titleIconSize),
              Text(
                " $title",
                style: TextStyle(
                  fontSize: sizes.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        else
          Text(
            title,
            style: TextStyle(
              fontSize: sizes.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        SizedBox(height: sizes.spacing),
        Card(
          child: Padding(padding: EdgeInsets.all(sizes.padding), child: child),
        ),
      ],
    );
  }
}
