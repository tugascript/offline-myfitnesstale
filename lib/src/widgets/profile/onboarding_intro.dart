import 'package:flutter/material.dart';

import '../../utilities/sizes/profile/onboarding_sizes.dart';
import '../layout/app_icon.dart';

class OnboardingIntro extends StatelessWidget {
  final OnboardingSizesList sizes;
  final String title;
  final String subtitle;

  const OnboardingIntro({
    super.key,
    required this.sizes,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          AppIcon(size: sizes.icon),
          SizedBox(height: sizes.breaks * 2),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: sizes.titleFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sizes.breaks),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: sizes.subtitleFontSize,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
