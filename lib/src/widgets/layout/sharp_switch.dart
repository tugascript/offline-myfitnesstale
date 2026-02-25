import 'package:flutter/material.dart';

class SharpSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final double thumbSize;
  final EdgeInsetsGeometry? padding;

  const SharpSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    required this.thumbSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final switchTheme = theme.switchTheme;
    final padding = this.padding ?? EdgeInsets.all(2.0);

    final activeColor =
        switchTheme.trackColor?.resolve({WidgetState.selected}) ??
            theme.colorScheme.primary;
    final inactiveColor =
        switchTheme.trackColor?.resolve({}) ?? theme.disabledColor;

    final thumbColor = switchTheme.thumbColor?.resolve(
          value ? {WidgetState.selected} : {},
        ) ??
        (value ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface);

    final trackWidth = thumbSize * 2.0;
    final trackHeight = thumbSize;

    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: trackWidth + padding.horizontal,
          height: trackHeight + padding.vertical,
          padding: padding,
          decoration: BoxDecoration(
            color: value ? activeColor : inactiveColor,
            // Sharp edges: no borderRadius
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    color: thumbColor,
                    // Sharp edges for thumb as well
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
