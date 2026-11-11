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
import '../../../core/widgets/base_carousel.dart';
import './active_meal_plan_widget.dart';
import './active_plan_widget.dart';

/// Keeps both feature widgets mounted and uses their natural maximum height.
/// Unlike a fixed-height PageView, this also fits asynchronously loaded content
/// and larger text without clipping or an inner vertical scroll area.
class ActivePlansCarousel extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const ActivePlansCarousel({
    super.key,
    required this.sizes,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCarousel(
      sizes: sizes,
      theme: theme,
      title: 'Active plans',
      keyPrefix: 'active-plans',
      labels: const ['Workout', 'Meal'],
      crossAxisAlignment: CrossAxisAlignment.stretch,
      semanticLabelBuilder: (label, index, total) =>
          '$label plan, ${index + 1} of $total',
      children: [
        ActivePlanWidget(sizes: sizes, showTitle: false),
        ActiveMealPlanWidget(theme: theme, sizes: sizes, showTitle: false),
      ],
    );
  }
}
