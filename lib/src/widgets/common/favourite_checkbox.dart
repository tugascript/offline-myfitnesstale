import 'package:flutter/material.dart';

class HeartCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double? size;
  final EdgeInsetsGeometry padding;

  const HeartCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onChanged(!value),
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
