import 'package:flutter/material.dart';

import '../../../services/dtos/workout_plan_dto.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/base_details_header.dart';
import '../../common/difficulty_badge.dart';
import '../../common/total_numeric_string.dart';

class WorkoutPlanHeader extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final WorkoutPlanDto plan;

  const WorkoutPlanHeader({
    super.key,
    required this.sizes,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final boxSpacing = sizes.spacing / 2;
    return BaseDetailsHeader(
      padding: sizes.padding,
      children: [
        Row(
          children: [
            Expanded(
              child: DifficultyBadge(
                spacing: sizes.spacing,
                difficulty: plan.difficulty,
                fontSize: sizes.smallFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              width: sizes.spacing,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TotalNumericString(
                    name: 'Weeks',
                    total: plan.totalWeeks,
                    fontSize: sizes.fontSize,
                  ),
                  SizedBox(
                    height: boxSpacing,
                  ),
                  TotalNumericString(
                    name: 'Days',
                    total: plan.totalDays,
                    fontSize: sizes.fontSize,
                  ),
                  SizedBox(
                    height: boxSpacing,
                  ),
                  TotalNumericString(
                    name: 'Workouts',
                    total: plan.totalWorkouts,
                    fontSize: sizes.fontSize,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (plan.description != null && plan.description!.isNotEmpty) ...[
          SizedBox(
            height: sizes.spacing,
          ),
          Text(
            'Description',
            style: TextStyle(
              fontSize: sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: boxSpacing,
          ),
          Wrap(
            spacing: boxSpacing,
            runSpacing: boxSpacing,
            children: [
              Text(
                plan.description!,
                style: TextStyle(
                  fontSize: sizes.fontSize,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
