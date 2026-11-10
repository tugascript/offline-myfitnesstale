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
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../view_models/weight_record_cubit.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../../data/repositories/weight/dtos/weight_goal_dto.dart';
import '../../../../core/utils/converters.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../goal_date.dart';
import '../goal_phase_badge.dart';
import '../goal_status_badge.dart';

class WeightGoalCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  final Units units;
  final WeightGoalDto weightGoal;

  const WeightGoalCard({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.weightGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(vertical: sizes.margins / 2),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Text(
                    _displayWeight(),
                    style: TextStyle(
                      fontSize: sizes.subtitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: sizes.spacing),
                Expanded(
                  child: GoalPhaseBadge(
                    phase: weightGoal.phase,
                    spacing: sizes.spacing / 2,
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: sizes.spacing,
                    runSpacing: sizes.spacing,
                    children: [
                      GoalDate(
                        icon: Icons.flag_outlined,
                        units: units,
                        date: weightGoal.startDate,
                        fontSize: sizes.fontSize,
                      ),
                      if (weightGoal.completedAt != null)
                        GoalDate(
                          icon: Icons.emoji_events_outlined,
                          units: units,
                          date: weightGoal.completedAt,
                          fontSize: sizes.fontSize,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.spacing),
            Row(
              children: [
                Expanded(
                  child: GoalStatusBadge(
                    status: weightGoal.status,
                    spacing: sizes.spacing / 2,
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: sizes.spacing),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.delete,
                    size: sizes.titleFontSize,
                    color: theme.colorScheme.brightness == Brightness.dark
                        ? Colors.red[400]
                        : Colors.red[600],
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Delete Weight Goal',
                        content: 'Are you sure you want to delete this weight goal? This action cannot be undone.',
                        onConfirm: () async {
                          await context
                              .read<WeightRecordCubit>()
                              .deleteWeightGoal(weightGoal.id);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _displayWeight() {
    switch (units) {
      case Units.metric:
        return "${Converters.gramsToKg(weightGoal.targetWeight).toStringAsFixed(2)}KG";
      case Units.imperial:
        return "${Converters.gramsToLbs(weightGoal.targetWeight).toStringAsFixed(2)}LBS";
    }
  }
}
