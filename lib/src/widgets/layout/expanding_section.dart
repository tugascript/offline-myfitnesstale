import 'package:flutter/material.dart';

class ExpandingSection extends StatelessWidget {
  final IconData? icon;
  final String title;
  final double titleFountSize;
  final FontWeight titleFontWeight;
  final String? subtitle;
  final double? subtitleFontSize;
  final double padding;
  final bool initiallyExpanded;
  final bool dense;
  final List<Widget> children;

  const ExpandingSection({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
    required this.titleFountSize,
    this.subtitleFontSize,
    required this.padding,
    this.initiallyExpanded = false,
    this.dense = false,
    this.titleFontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      dense: dense,
      leading: Icon(
        icon,
        size: titleFountSize * 1.2,
      ),
      maintainState: true,
      initiallyExpanded: initiallyExpanded,
      title: Text(
        title,
        style: TextStyle(
          fontSize: titleFountSize,
          fontWeight: titleFontWeight,
        ),
      ),
      subtitle: subtitle != null && subtitleFontSize != null
          ? Text(
              subtitle!,
              style: TextStyle(fontSize: subtitleFontSize),
            )
          : null,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: padding,
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
