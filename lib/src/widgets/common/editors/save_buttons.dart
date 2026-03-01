import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import '../../layout/app_primary_button.dart';
import '../mutation_button.dart';

class SaveButtons extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  const SaveButtons({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MutationButton(
            onPressed: onCancel,
            theme: theme,
            isLoading: isLoading,
            sizes: sizes,
            label: 'CANCEL',
            icon: Icons.cancel,
            color: theme.colorScheme.error,
          ),
        ),
        SizedBox(width: sizes.spacing / 2),
        Expanded(
          child: AppPrimaryButton(
            onPressed: onSave,
            theme: theme,
            isLoading: isLoading,
            sizes: sizes,
            label: 'SAVE',
            icon: Icons.save,
          ),
        ),
      ],
    );
  }
}
