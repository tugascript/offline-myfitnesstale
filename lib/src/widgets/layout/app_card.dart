import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final double? padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: BeveledRectangleBorder(),
      child: child,
    );
  }
}
