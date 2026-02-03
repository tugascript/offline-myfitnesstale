import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final double? padding;
  final Color? color;
  final double elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: BeveledRectangleBorder(),
      color: color,
      child: child,
    );
  }
}
