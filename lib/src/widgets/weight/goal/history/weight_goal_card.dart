import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/weight_record_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/weight_goal_dto.dart';
import '../../../../utilities/converters.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/confirmation_dialog.dart';
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
      margin: EdgeInsets.symmetric(
        vertical: sizes.margins / 2,
      ),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Text(
                    "${_displayWeight()} ${units == Units.imperial ? 'LBS' : 'KG'}",
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
                        content:
                            'Are you sure you want to delete this weight goal? This action cannot be undone.',
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
    if (units == Units.imperial) {
      return Converters.gramsToLbs(weightGoal.targetWeight).toStringAsFixed(2);
    }

    return Converters.gramsToKg(weightGoal.targetWeight).toStringAsFixed(2);
  }
}
