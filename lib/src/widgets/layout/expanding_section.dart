import 'package:flutter/material.dart';

class ExpandingSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final double titleFountSize;
  final String subtitle;
  final double subtitleFontSize;
  final double padding;
  final List<Widget> children;

  const ExpandingSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.titleFountSize,
    required this.subtitleFontSize,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(
        icon,
        size: titleFountSize * 1.2,
      ),
      maintainState: true,
      title: Text(
        title,
        style: TextStyle(
          fontSize: titleFountSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: subtitleFontSize),
      ),
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
