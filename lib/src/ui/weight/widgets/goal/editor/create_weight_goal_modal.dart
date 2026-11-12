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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../data/repositories/weight/inputs/weight_goal_input.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../../utils/nullable.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/layout/app_modal.dart';
import '../../../../home/view_models/profile_cubit.dart';
import '../../../../home/view_models/states/profile_state.dart';
import '../../../view_models/states/weight_record_state.dart';
import '../../../view_models/weight_record_cubit.dart';
import './weight_goal_form.dart';

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
                onSubmit:
                    ({required phase, required weight, fatPercentage}) async {
                      await context.read<WeightRecordCubit>().createWeightGoal(
                        WeightGoalInput(
                          targetWeight: weight,
                          targetFatPercentage: Nullable(fatPercentage),
                          startDate: DateTime.now(),
                          phase: phase,
                        ),
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
