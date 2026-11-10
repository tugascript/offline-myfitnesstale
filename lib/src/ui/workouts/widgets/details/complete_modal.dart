import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/active_workout_cubit.dart';
import '../../../core/widgets/confirmation_dialog.dart';

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
