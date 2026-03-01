import 'package:flutter/material.dart';

class ModalSearchEntityName extends StatelessWidget {
  final String name;
  final bool isFavorite;
  final double fontSize;

  const ModalSearchEntityName({
    super.key,
    required this.name,
    required this.isFavorite,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFavorite) {
      return Text(
        name,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      children: [
        Text(
          "$name ",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
        Icon(
          Icons.favorite,
          color: Colors.red,
          size: fontSize * 1.2,
        ),
      ],
    );
  }
}
