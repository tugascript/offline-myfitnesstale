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

import '../../../data/utils/enums.dart';

class CreatedByCheckbox extends StatelessWidget {
  final CreatedBy? value;
  final ValueChanged<CreatedBy?> onChanged;
  final double? size;
  final EdgeInsetsGeometry padding;
  final String? tooltip;

  const CreatedByCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size,
    this.padding = EdgeInsets.zero,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = value == CreatedBy.user;

    return IconButton(
      onPressed: () => onChanged(isUser ? null : CreatedBy.user),
      tooltip:
          tooltip ?? (isUser ? 'Show all items' : 'Filter by created by user'),
      icon: Icon(
        isUser ? Icons.person : Icons.person_outline,
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
