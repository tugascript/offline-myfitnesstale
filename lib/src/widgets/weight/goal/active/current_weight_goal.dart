import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../cubits/profile_cubit.dart';
import '../../../../cubits/states/profile_state.dart';
import '../../../../cubits/weight_record_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/weight_goal_dto.dart';
import '../../../../utilities/converters.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../common/confirmation_dialog.dart';
import '../goal_date.dart';
import '../goal_phase_badge.dart';
import '../goal_status_badge.dart';

class CurrentWeightGoal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  final WeightGoalDto? weightGoal;
  final bool isLoading;
  final VoidCallback onEdit;

  const CurrentWeightGoal({
    super.key,
    required this.weightGoal,
    required this.isLoading,
    required this.theme,
    required this.sizes,
    required this.onEdit,
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
          child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
            return Skeletonizer(
              enabled: isLoading || weightGoal == null,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Current Weight Goal",
                        style: TextStyle(
                          fontSize: sizes.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.edit_outlined,
                          size: sizes.titleFontSize * 1.2,
                          color: theme.colorScheme.brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                        onPressed: onEdit,
                      ),
                    ],
                  ),
                  SizedBox(height: sizes.spacing),
                  Text(
                    state.system?.units == Units.imperial
                        ? "${Converters.gramsToLbs(
                            weightGoal?.targetWeight ?? 0,
                          ).toStringAsFixed(2)} LBS"
                        : "${Converters.gramsToKg(
                            weightGoal?.targetWeight ?? 0,
                          ).toStringAsFixed(2)} KG",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sizes.subtitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: sizes.spacing),
                  Row(
                    children: [
                      Expanded(
                        child: GoalPhaseBadge(
                          phase: weightGoal?.phase,
                          spacing: sizes.spacing / 2,
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: sizes.spacing),
                      Expanded(
                        child: GoalStatusBadge(
                          status: weightGoal?.status,
                          spacing: sizes.spacing / 2,
                          fontSize: sizes.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sizes.spacing),
                  Row(
                    children: [
                      Expanded(
                        child: GoalDate(
                          icon: Icons.flag_outlined,
                          units: state.system?.units ?? Units.imperial,
                          date: weightGoal?.startDate,
                          fontSize: sizes.fontSize,
                        ),
                      ),
                      if (weightGoal?.completedAt != null) ...[
                        SizedBox(width: sizes.spacing),
                        Expanded(
                          child: GoalDate(
                            icon: Icons.emoji_events_outlined,
                            units: state.system?.units ?? Units.imperial,
                            date: weightGoal?.completedAt,
                            fontSize: sizes.fontSize,
                          ),
                        ),
                      ],
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
                                if (weightGoal != null) {
                                  await context
                                      .read<WeightRecordCubit>()
                                      .deleteWeightGoal(weightGoal!.id);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
