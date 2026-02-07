import 'package:flutter/material.dart';

class DetailNumber extends StatelessWidget {
  final int number;
  final ThemeData theme;
  final double fontSize;

  const DetailNumber({
    super.key,
    required this.number,
    required this.theme,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fontSize * 1.75,
      height: fontSize * 1.75,
      decoration: BoxDecoration(
        color: theme.primaryColor,
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
