import 'package:flutter/material.dart';

class BaseDetailsHeader extends StatelessWidget {
  final double padding;
  final List<Widget> children;

  const BaseDetailsHeader({
    super.key,
    required this.padding,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
