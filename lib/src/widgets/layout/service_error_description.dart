import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/sizes/font_size.dart';
import '../../utilities/sizes/screen_size.dart';

class ServiceErrorDescription extends StatelessWidget {
  final String description;

  const ServiceErrorDescription({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final BreakPoint breakPoint = BreakPoint.fromContext(context);
    final double fontSize = FontSize.getFontSize(breakPoint.screenSize);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: fontSize, color: Colors.grey),
          SizedBox(height: fontSize),
          Text(
            description,
            style: TextStyle(fontSize: fontSize, color: Colors.grey),
          ),
          SizedBox(height: fontSize),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: Text(
              'Go Back',
              style: TextStyle(fontSize: fontSize * 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
