// Copyright (C) 2026 afonsobarracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

import '../../../core/sizes/profile/onboarding_sizes.dart';
import '../../../core/widgets/layout/app_icon.dart';

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
          ),
        ],
      ),
    );
  }
}
