import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final double margin;
  final double padding;
  final List<Widget> children;
  final void Function() onTap;

  const ListCard({
    super.key,
    required this.margin,
    required this.padding,
    required this.children,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(
        vertical: margin,
        horizontal: margin / 2,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
