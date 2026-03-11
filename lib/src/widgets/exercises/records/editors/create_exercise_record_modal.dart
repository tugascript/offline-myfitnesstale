import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/exercise_record_cubit.dart';
import '../../../../cubits/states/exercise_record_state.dart';
import '../../../../models/enums.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_modal.dart';
import 'exercise_record_form.dart';

class CreateExerciseRecordModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final int exerciseId;

  const CreateExerciseRecordModal({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
        builder: (context, state) {
          return ExerciseRecordForm(
            theme: theme,
            sizes: sizes,
            units: units,
            exerciseId: exerciseId,
            isLoading: state.isLoading,
            submitLabel: "CREATE EXERCISE RECORD",
            initialDate: DateTime.now(),
            initialWeight: 0,
            initialReps: 1,
            onSubmit: ({
              required int exerciseId,
              required int weight,
              required int reps,
              required DateTime date,
            }) async {
              await context.read<ExerciseRecordCubit>().createExerciseRecord(
                    exerciseId: exerciseId,
                    weight: weight,
                    reps: reps,
                    date: date,
                  );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          );
        },
      ),
    );
  }
}
