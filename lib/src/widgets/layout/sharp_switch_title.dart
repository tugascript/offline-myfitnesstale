import 'package:flutter/material.dart';

import 'sharp_switch.dart';

class SharpSwitchTitle extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry? switchPadding;
  final double? thumbSize;

  const SharpSwitchTitle({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.contentPadding,
    this.switchPadding,
    this.titleStyle,
    this.thumbSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: titleStyle ?? Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            SharpSwitch(
              value: value,
              onChanged: onChanged,
              padding: switchPadding,
              thumbSize: thumbSize ?? 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
