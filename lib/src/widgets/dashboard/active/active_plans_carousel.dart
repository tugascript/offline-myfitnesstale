import 'package:flutter/material.dart';

import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/base_carousel.dart';
import 'active_meal_plan_widget.dart';
import 'active_plan_widget.dart';

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
