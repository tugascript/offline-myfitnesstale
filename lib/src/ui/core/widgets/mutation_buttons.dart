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

import '../sizes/data_display_sizes.dart';
import './mutation_button.dart';

class MutationButtons extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final double? padding;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MutationButtons({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ?? sizes.padding / 3),
      child: Row(
        children: [
          Expanded(
            child: MutationButton(
              isLoading: isLoading,
              theme: theme,
              sizes: sizes,
              onPressed: onEdit,
              label: 'EDIT',
              icon: Icons.edit,
            ),
          ),
          SizedBox(width: sizes.spacing),
          Expanded(
            child: MutationButton(
              isLoading: isLoading,
              theme: theme,
              sizes: sizes,
              onPressed: onDelete,
              label: 'DELETE',
              icon: Icons.delete,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
