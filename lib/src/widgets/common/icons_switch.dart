import 'package:flutter/material.dart';

import '../layout/sharp_switch.dart';

class IconsSwitch extends StatelessWidget {
  final ThemeData theme;
  final IconData offIcon;
  final IconData onIcon;
  final bool switchOn;
  final double iconSize;
  final double spacing;
  final double switchPadding;
  final double thumbSize;
  final ValueChanged<bool> onChanged;

  const IconsSwitch({
    super.key,
    required this.theme,
    required this.offIcon,
    required this.onIcon,
    required this.switchOn,
    required this.spacing,
    required this.switchPadding,
    required this.thumbSize,
    required this.iconSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          offIcon,
          size: iconSize,
          color: switchOn
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.primary,
        ),
        SizedBox(width: spacing),
        SharpSwitch(
          value: switchOn,
          onChanged: onChanged,
          thumbSize: thumbSize,
          padding: EdgeInsets.all(switchPadding),
        ),
        SizedBox(width: spacing),
        Icon(
          onIcon,
          size: iconSize,
          color: switchOn
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}
