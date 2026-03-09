import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/states/weight_record_state.dart';
import '../../../../cubits/weight_record_cubit.dart';
import '../../../../models/enums.dart';
import '../../../../services/dtos/weight_record_dto.dart';
import '../../../../utilities/sizes/data_display_sizes.dart';
import '../../../layout/app_modal.dart';
import 'weight_record_form.dart';

class EditWeightRecordModal extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final WeightRecordDto record;

  const EditWeightRecordModal({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return AppModal(
      theme: theme,
      sizes: sizes,
      child: BlocBuilder<WeightRecordCubit, WeightRecordState>(
        builder: (context, state) {
          return WeightRecordForm(
            theme: theme,
            sizes: sizes,
            isLoading: state.isLoading,
            submitLabel: "UPDATE WEIGHT LOG",
            submitIcon: Icons.save,
            initialDate: record.recordDate,
            initialWeight: record.weight,
            initialBodyFatPercentage: record.fatPercentage,
            units: units,
            onSubmit: ({
              int? bodyFat,
              required DateTime date,
              required int weight,
            }) async {
              await context.read<WeightRecordCubit>().updateWeightRecord(
                    id: record.id,
                    weight: weight,
                    date: date,
                    fatPercentage: bodyFat,
                  );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          );
        },
      ),
    );
  }
}
