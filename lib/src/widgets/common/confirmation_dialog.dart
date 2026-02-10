import 'package:flutter/material.dart';

// TODO: make it responsive
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: BeveledRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            cancelLabel.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: isDestructive ? theme.colorScheme.error : null,
          ),
          child: Text(
            confirmLabel.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
