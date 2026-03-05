import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/profile_cubit.dart';
import '../../../../cubits/states/profile_state.dart';
import '../../../../cubits/states/weight_record_state.dart';
import '../../../../cubits/weight_record_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_modal.dart';
import 'weight_goal_form.dart';

class CreateWeightGoalModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const CreateWeightGoalModal({
    super.key,
    required this.theme,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          return BlocBuilder<WeightRecordCubit, WeightRecordState>(
            builder: (context, weightRecordState) {
              return WeightGoalForm(
                theme: theme,
                sizes: sizes,
                isLoading: weightRecordState.isLoading,
                submitLabel: "CREATE WEIGHT GOAL",
                initialWeight: 0,
                initialPhase: WeightGoalPhase.cut,
                onSubmit: ({required phase, required weight}) async {
                  await context.read<WeightRecordCubit>().createWeightGoal(
                        targetWeight: weight,
                        phase: phase,
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                units: profileState.system?.units ?? Units.metric,
              );
            },
          );
        },
      ),
    );
  }
}
