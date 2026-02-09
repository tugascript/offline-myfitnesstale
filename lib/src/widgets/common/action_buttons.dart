import 'package:flutter/material.dart';
import '../../utilities/sizes/data_display_sizes.dart';
import 'edit_button.dart';

class ActionButtons extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  // Primary Action (e.g. Start)
  final VoidCallback? onStart;
  final String startLabel;
  final IconData startIcon;

  // Edit Action
  final VoidCallback? onEdit;
  final String editLabel;
  final IconData editIcon;

  // History Action
  final VoidCallback? onHistory;
  final String historyLabel;
  final IconData historyIcon;

  const ActionButtons({
    super.key,
    required this.theme,
    required this.sizes,
    this.onStart,
    this.startLabel = 'START',
    this.startIcon = Icons.play_arrow,
    this.onEdit,
    this.editLabel = 'EDIT',
    this.editIcon = Icons.edit,
    this.onHistory,
    this.historyLabel = 'HISTORY',
    this.historyIcon = Icons.history,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _PrimaryButton(
                theme: theme,
                sizes: sizes,
                onPressed: onStart,
                label: startLabel,
                icon: startIcon,
              ),
            ),
            SizedBox(width: sizes.spacing),
            EditButton(
              theme: theme,
              sizes: sizes,
              onPressed: onEdit,
              label: editLabel,
              icon: editIcon,
            ),
          ],
        ),
        SizedBox(height: sizes.spacing),
        Row(
          children: [
            Expanded(
              child: _TertiaryButton(
                theme: theme,
                sizes: sizes,
                onPressed: onHistory,
                label: historyLabel,
                icon: historyIcon,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;

  const _PrimaryButton({
    required this.theme,
    required this.sizes,
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
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
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: sizes.padding),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.scaffoldBackgroundColor,
        shape: BeveledRectangleBorder(),
      ),
    );
  }
}

class _TertiaryButton extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;

  const _TertiaryButton({
    required this.theme,
    required this.sizes,
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: sizes.subtitleFontSize,
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
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.scaffoldBackgroundColor,
        shape: BeveledRectangleBorder(),
      ),
    );
  }
}
