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

import 'package:flutter/material.dart';

import '../../sizes/data_display_sizes.dart';

/// Keeps fields usable when the available width or text scale changes.
class ResponsiveFields extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final List<Widget> children;

  const ResponsiveFields({
    super.key,
    required this.sizes,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (children.isEmpty) return const SizedBox.shrink();
      final fieldWidth = MediaQuery.textScalerOf(context)
          .scale(sizes.formFieldMinWidth);
      final columns =
          ((constraints.maxWidth + sizes.spacing) /
                  (fieldWidth + sizes.spacing))
              .floor()
              .clamp(1, children.length);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var start = 0; start < children.length; start += columns) ...[
            if (start > 0) SizedBox(height: sizes.inputSpacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (
                  var index = start;
                  index < start + columns && index < children.length;
                  index++
                ) ...[
                  if (index > start) SizedBox(width: sizes.spacing),
                  Expanded(child: children[index]),
                ],
              ],
            ),
          ],
        ],
      );
    },
  );
}
