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

class HeartCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double? size;
  final EdgeInsetsGeometry padding;
  final String? tooltip;

  const HeartCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size,
    this.padding = EdgeInsets.zero,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onChanged(!value),
      tooltip: tooltip ?? (value ? 'Show all items' : 'Filter by favorites'),
      icon: Icon(
        value ? Icons.favorite : Icons.favorite_border,
        color: Theme.of(context).colorScheme.secondary,
        size: size,
      ),
      padding: padding,
      constraints: const BoxConstraints(),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
