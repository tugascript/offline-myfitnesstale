import 'package:flutter/material.dart';

import '../../utilities/sizes/data_display_sizes.dart';

class AppPrimaryButton extends StatelessWidget {
  final ThemeData theme;
  final bool isLoading;
  final DataDisplaySizesList sizes;
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;

  const AppPrimaryButton({
    super.key,
    required this.theme,
    required this.isLoading,
    required this.sizes,
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final greyColor = theme.colorScheme.brightness == Brightness.light
        ? Colors.grey[400]
        : Colors.grey[600];
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(
        icon,
        size: sizes.fontSize * 1.2,
        fontWeight: FontWeight.w600,
      ),
      label: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: sizes.subtitleFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: sizes.padding),
        backgroundColor: isLoading ? greyColor : theme.primaryColor,
        foregroundColor: theme.scaffoldBackgroundColor,
        shape: BeveledRectangleBorder(),
      ),
    );
  }
}
