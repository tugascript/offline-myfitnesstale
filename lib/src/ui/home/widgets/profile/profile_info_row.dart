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

class ProfileInfoRow extends StatelessWidget {
  final String name;
  final Color titleColor;
  final DataDisplaySizesList sizes;
  final String value;

  const ProfileInfoRow({
    super.key,
    required this.name,
    required this.titleColor,
    required this.value,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: sizes.profileLabelWidth,
          child: Text(
            name,
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: sizes.subtitleFontSize),
          ),
        ),
      ],
    );
  }
}
