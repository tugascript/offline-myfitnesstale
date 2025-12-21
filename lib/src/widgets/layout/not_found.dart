import 'package:flutter/material.dart';

import '../../utilities/sizes/font_size.dart';
import '../../utilities/sizes/screen_size.dart';

class NotFound extends StatelessWidget {
  const NotFound({super.key});

  @override
  Widget build(BuildContext context) {
    final BreakPoint breakPoint = BreakPoint.fromContext(context);
    final double fontSize = FontSize.getFontSize(breakPoint.screenSize);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'PAGE NOT FOUND',
          style: TextStyle(
            fontSize: fontSize * 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Icon(
          Icons.broken_image_rounded,
          size: fontSize * 7,
        ),
      ],
    );
  }
}
