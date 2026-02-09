import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';

class EditButton extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;

  const EditButton({
    super.key,
    required this.theme,
    required this.sizes,
    required this.onPressed,
    this.label = 'EDIT',
    this.icon = Icons.edit,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: sizes.fontSize,
        fontWeight: FontWeight.w600,
      ),
      label: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: sizes.subtitleFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: sizes.padding),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(
          color: theme.colorScheme.primary,
          width: 1,
        ),
        shape: BeveledRectangleBorder(),
      ),
    );
  }
}
