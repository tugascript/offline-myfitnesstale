import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';

class MutationButton extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color? color;
  final String label;
  final IconData icon;
  final bool isDense;

  const MutationButton({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.onPressed,
    this.color,
    this.label = 'EDIT',
    this.icon = Icons.edit,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    final lightGrey = theme.brightness == Brightness.light
        ? Colors.grey[400]
        : Colors.grey[600];
    final baseColor = (color ?? theme.colorScheme.primary);
    final btnColor = isLoading ? lightGrey! : baseColor;
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
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
        visualDensity: isDense ? VisualDensity.compact : VisualDensity.standard,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: btnColor,
        side: BorderSide(
          color: btnColor,
          width: 1,
        ),
        shape: const BeveledRectangleBorder(),
      ),
    );
  }
}
