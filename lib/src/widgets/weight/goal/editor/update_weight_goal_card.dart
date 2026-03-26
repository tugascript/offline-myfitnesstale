import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/profile_cubit.dart';
import '../../../../cubits/states/profile_state.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/weight_goal_dto.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import 'weight_goal_form.dart';

class UpdateWeightGoalCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final WeightGoalDto weightGoal;
  final bool isLoading;
  final String submitLabel;
  final int initialWeight;
  final WeightGoalPhase initialPhase;
  final void Function({
    required int weight,
    required WeightGoalPhase phase,
  }) onSubmit;
  final VoidCallback onClose;

  const UpdateWeightGoalCard({
    super.key,
    required this.theme,
    required this.sizes,
    required this.weightGoal,
    required this.isLoading,
    required this.submitLabel,
    required this.initialWeight,
    required this.initialPhase,
    required this.onSubmit,
    required this.onClose,
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
                      Icons.close,
                      size: sizes.titleFontSize * 1.2,
                      color: theme.colorScheme.brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    onPressed: onClose,
                  ),
                ],
              ),
              SizedBox(height: sizes.spacing),
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  return WeightGoalForm(
                    theme: theme,
                    units: state.system?.units ?? Units.metric,
                    sizes: sizes,
                    isLoading: isLoading,
                    submitLabel: submitLabel,
                    initialWeight: initialWeight,
                    initialPhase: initialPhase,
                    onSubmit: onSubmit,
                    submitIcon: Icons.save,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
