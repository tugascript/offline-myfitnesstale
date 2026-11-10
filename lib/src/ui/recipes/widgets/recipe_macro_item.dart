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

class RecipeMacroItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final DataDisplaySizesList sizes;

  const RecipeMacroItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: sizes.spacing / 2),
        Text(
          label,
          style: TextStyle(fontSize: sizes.fontSize * 0.8, color: Colors.grey),
        ),
      ],
    );
  }
}
