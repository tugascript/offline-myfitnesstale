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

import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/layout/app_text_button.dart';
import '../../../../core/widgets/layout/empty_card.dart';

class EmptyWorkoutRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final int? workoutId;
  final int? workoutVersion;

  const EmptyWorkoutRecord({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.workoutId,
    required this.workoutVersion,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyCard(
      sizes: sizes,
      emoji: '🏋️',
      emptyText: 'No workout records',
      actions: [
        if (workoutId != null)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: sizes.halfSpacing,
            runSpacing: sizes.halfSpacing,
            children: [
              AppTextButton(
                isLoading: isLoading,
                sizes: sizes,
                isDense: true,
                onPressed: () => context.push('/workouts/$workoutId/active'),
                label: 'Start Workout',
                icon: Icons.play_arrow,
              ),
              AppTextButton(
                isLoading: isLoading,
                sizes: sizes,
                isDense: true,
                isSecondary: true,
                onPressed: () => context.push(
                  '/workouts/$workoutId/history/${workoutVersion ?? 1}/records/create',
                ),
                label: 'Create Record',
                icon: Icons.add,
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: AppTextButton(
              isLoading: isLoading,
              sizes: sizes,
              isDense: true,
              onPressed: () => context.push('/workouts'),
              label: 'Browse Workouts',
              icon: Icons.fitness_center,
            ),
          ),
      ],
    );
  }
}
