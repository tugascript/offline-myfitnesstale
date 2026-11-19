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
import '../../../core/widgets/layout/app_text_button.dart';
import './create_strength_goal_modal.dart';

class EmptyActiveStrengthGoalCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;

  const EmptyActiveStrengthGoalCard({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = theme.brightness == Brightness.dark;
    final subtitleColor = isDarkTheme ? Colors.grey[400] : Colors.grey[600];

    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sizes.padding,
            vertical: sizes.padding * 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_outlined, size: sizes.titleFontSize * 2),
              SizedBox(height: sizes.spacing),
              Text(
                'No Active Strength Goal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sizes.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: sizes.halfSpacing),
              Text(
                'Set a target weight and reps for an exercise to stay motivated.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sizes.fontSize,
                  color: subtitleColor,
                ),
              ),
              SizedBox(height: sizes.spacing),
              SizedBox(
                width: double.infinity,
                child: AppTextButton(
                  key: const ValueKey('strength-goal-set-active-button'),
                  isLoading: isLoading,
                  sizes: sizes,
                  isDense: true,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) =>
                          CreateStrengthGoalModal(theme: theme, sizes: sizes),
                    );
                  },
                  label: 'Set Goal',
                  icon: Icons.add,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
