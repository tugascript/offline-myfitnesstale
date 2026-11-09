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
