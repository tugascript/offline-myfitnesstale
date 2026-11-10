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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../home/view_models/profile_cubit.dart';
import '../../../../home/view_models/states/profile_state.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../../data/repositories/weight/dtos/weight_goal_dto.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import './weight_goal_form.dart';

class UpdateWeightGoalCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final WeightGoalDto weightGoal;
  final bool isLoading;
  final String submitLabel;
  final int initialWeight;
  final WeightGoalPhase initialPhase;
  final int? initialFatPercentage;
  final void Function({
    required int weight,
    required WeightGoalPhase phase,
    int? fatPercentage,
  })
  onSubmit;
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
    this.initialFatPercentage,
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
                    initialFatPercentage: initialFatPercentage,
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
