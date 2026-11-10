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

import '../../../core/sizes/data_display_sizes.dart';

/// Lets carousel cards stretch while standalone cards keep their heading.
class ActivePlanFrame extends StatelessWidget {
  final String title;
  final bool showTitle;
  final DataDisplaySizesList sizes;
  final Widget child;

  const ActivePlanFrame({
    super.key,
    required this.title,
    required this.showTitle,
    required this.sizes,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!showTitle) return Column(children: [Expanded(child: child)]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: sizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: sizes.spacing),
        child,
      ],
    );
  }
}
