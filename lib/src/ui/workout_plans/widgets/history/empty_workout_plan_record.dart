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

import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/layout/app_text_button.dart';
import '../../../core/widgets/layout/empty_card.dart';

class EmptyWorkoutPlanRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final int? workoutPlanId;

  const EmptyWorkoutPlanRecord({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.workoutPlanId,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyCard(
      sizes: sizes,
      emoji: '📋',
      emptyText: 'No workout plan records',
      actions: [
        if (workoutPlanId != null)
          SizedBox(
            width: double.infinity,
            child: AppTextButton(
              isLoading: isLoading,
              sizes: sizes,
              isDense: true,
              onPressed: () =>
                  context.push('/workout-plans/$workoutPlanId/active'),
              label: 'Start Plan',
              icon: Icons.play_arrow,
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: AppTextButton(
              isLoading: isLoading,
              sizes: sizes,
              isDense: true,
              onPressed: () => context.push('/workout-plans'),
              label: 'Browse Plans',
              icon: Icons.view_list,
            ),
          ),
      ],
    );
  }
}
