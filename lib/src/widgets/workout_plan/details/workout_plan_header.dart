import 'package:flutter/material.dart';

import '../../../models/enums.dart';
import '../../../services/dtos/workout_plan_dto.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/base_details_header.dart';
import '../../common/difficulty_badge.dart';

class WorkoutPlanHeader extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final WorkoutPlanDto plan;
  final Widget? actionButtonIcon;
  final VoidCallback actionButtonPress;

  const WorkoutPlanHeader({
    super.key,
    required this.sizes,
    required this.plan,
    this.actionButtonIcon,
    required this.actionButtonPress,
  });

  @override
  Widget build(BuildContext context) {
    final boxSpacing = sizes.spacing / 2;
    return BaseDetailsHeader(
      padding: sizes.padding,
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sizes.spacing),
              child: Icon(
                plan.createdBy == CreatedBy.user ? Icons.person : Icons.public,
                color: plan.createdBy == CreatedBy.user
                    ? Colors.blue
                    : Colors.grey,
              ),
            ),
            Expanded(
              child: DifficultyBadge(
                spacing: sizes.spacing,
                difficulty: plan.difficulty,
                fontSize: sizes.smallFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              key: ValueKey(
                actionButtonIcon == null
                    ? 'workout-plan-favorite'
                    : 'workout-plan-header-edit',
              ),
              icon: actionButtonIcon ??
                  Icon(
                    plan.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: plan.isFavorite ? Colors.red : null,
                  ),
              onPressed: actionButtonPress,
              tooltip: plan.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
            ),
          ],
        ),
        Text(
          'Totals',
          style: TextStyle(
            fontSize: sizes.subtitleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: boxSpacing,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TotalString(
              sizes: sizes,
              icon: Icons.calendar_month,
              name: 'Weeks',
              total: plan.totalWeeks,
            ),
            _TotalString(
              sizes: sizes,
              icon: Icons.calendar_today,
              name: 'Days',
              total: plan.totalDays,
            ),
            Row(
              children: [
                Text("🏋️", style: TextStyle(fontSize: sizes.fontSize * 1.2)),
                SizedBox(
                  width: sizes.spacing / 2,
                ),
                Text(
                  " Workouts: ",
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  plan.totalWorkouts.toString(),
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                  ),
                ),
              ],
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

class _TotalString extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final IconData icon;
  final String name;
  final int total;

  const _TotalString({
    required this.sizes,
    required this.icon,
    required this.name,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: sizes.fontSize * 1.2),
        SizedBox(
          width: sizes.spacing / 2,
        ),
        Text(
          " $name: ",
          style: TextStyle(
            fontSize: sizes.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          total.toString(),
          style: TextStyle(
            fontSize: sizes.fontSize,
          ),
        ),
      ],
    );
  }
}
