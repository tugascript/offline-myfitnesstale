import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/profile_cubit.dart';
import '../../../../cubits/states/profile_state.dart';
import '../../../../cubits/states/weight_record_state.dart';
import '../../../../cubits/weight_record_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_modal.dart';
import 'weight_record_form.dart';

class CreateWeightRecordModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  const CreateWeightRecordModal({
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
        builder: (context, profileState) =>
            BlocBuilder<WeightRecordCubit, WeightRecordState>(
          builder: (context, weightRecordState) => WeightRecordForm(
            theme: theme,
            sizes: sizes,
            isLoading: weightRecordState.isLoading,
            submitLabel: "LOG WEIGHT",
            initialDate: DateTime.now(),
            initialWeight: 0,
            units: profileState.system?.units ?? Units.metric,
            onSubmit: ({
              int? bodyFat,
              required DateTime date,
              required int weight,
            }) async {
              await context.read<WeightRecordCubit>().createWeightRecord(
                    weight: weight,
                    date: date,
                    fatPercentage: bodyFat,
                  );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
