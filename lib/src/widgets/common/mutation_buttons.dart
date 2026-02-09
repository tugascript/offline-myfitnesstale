import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';
import 'mutation_button.dart';

class MutationButtons extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MutationButtons({
    super.key,
    required this.theme,
    required this.sizes,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sizes.padding / 3),
      child: Row(
        children: [
          Expanded(
            child: MutationButton(
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
