// Copyright (C) 2026 Afonso Barracha
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

import 'package:material_ui/material_ui.dart';

import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/themes/colors.dart';
import '../../../core/widgets/layout/app_icon.dart';

class OnboardingIntro extends StatelessWidget {
  final DataDisplaySizesList sizes;
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

    return Center(
      child: Column(
        children: [
          AppIcon(size: sizes.mainIconSize),
          SizedBox(height: sizes.doubleSpacing),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: sizes.mainTitleFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sizes.spacing),
          Text(
            subtitle,
            style: TextStyle(
              color: ThemedColors.themedGrey.fromBrightness(theme.brightness),
              fontSize: sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
