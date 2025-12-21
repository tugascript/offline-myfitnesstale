import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  final double size;

  const AppIcon({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final String iconPath =
        'assets/icons/icon_${isLightTheme ? 'light' : 'dark'}.svg';

    return GestureDetector(
      child: SvgPicture.asset(
        iconPath,
        height: size,
        width: size,
        fit: BoxFit.contain,
        placeholderBuilder: (BuildContext context) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.fitness_center,
            size: size * 0.6,
            color: Theme.of(context).primaryColor,
          ),
        ),
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          debugPrint('Failed to load SVG icon: $iconPath - $exception');
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fitness_center,
              size: size * 0.6,
              color: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }
}
