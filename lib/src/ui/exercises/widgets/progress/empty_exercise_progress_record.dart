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

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../routing/routes.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_text_button.dart';

class EmptyExerciseProgressRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final bool isLoading;

  const EmptyExerciseProgressRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
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
              Text(
                "💪",
                style: TextStyle(
                  fontSize: sizes.titleFontSize * 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: sizes.spacing),
              Text(
                "No exercise records",
                style: TextStyle(
                  fontSize: sizes.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: sizes.spacing),
              SizedBox(
                width: double.infinity,
                child: AppTextButton(
                  isLoading: isLoading,
                  sizes: sizes,
                  isDense: true,
                  onPressed: () => context.push(Routes.exercises.name),
                  label: 'Browse Exercises',
                  icon: Icons.sports_gymnastics,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
