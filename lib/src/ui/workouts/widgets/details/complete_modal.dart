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

import '../../../core/widgets/confirmation_dialog.dart';
import '../../view_models/active_workout_cubit.dart';

class CompleteWorkoutDialog extends StatelessWidget {
  final String workoutName;

  const CompleteWorkoutDialog({super.key, required this.workoutName});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ActiveWorkoutCubit>();
    return ConfirmationDialog(
      title: 'Complete Workout',
      content: 'Are you sure you want to complete $workoutName workout?',
      confirmLabel: 'Yes',
      cancelLabel: 'No',
      onConfirm: () async {
        if (context.mounted) {
          await cubit.completeWorkout();
        }
      },
    );
  }
}
