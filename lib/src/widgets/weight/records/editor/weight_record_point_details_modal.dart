import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/weight_record_cubit.dart';
import '../../../../data/utils/enums.dart';
import 'package:myfitnesstale/src/data/repositories/weight/dtos/weight_record_dto.dart';
import '../../../../ui/core/utils/converters.dart';
import '../../../../ui/core/utils/formatters.dart';
import '../../../../ui/core/sizes/data_display_sizes.dart';
import '../../../../ui/core/widgets/confirmation_dialog.dart';
import '../../../../ui/core/widgets/mutation_buttons.dart';
import '../../../layout/app_modal.dart';
import 'edit_weight_record_modal.dart';

class WeightRecordPointDetailsModal extends StatelessWidget {
  final BuildContext parentContext;
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;
  final WeightRecordDto record;

  const WeightRecordPointDetailsModal({
    super.key,
    required this.parentContext,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.record,
  });

  static Future<void> show({
    required BuildContext context,
    required ThemeData theme,
    required DataDisplaySizesList sizes,
    required Units units,
    required WeightRecordDto record,
  }) {
    final parentContext = context;
    return showDialog(
      context: context,
      builder: (context) => WeightRecordPointDetailsModal(
        parentContext: parentContext,
        theme: theme,
        sizes: sizes,
        units: units,
        record: record,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightValue = units == Units.metric
        ? Converters.gramsToKg(record.weight).toStringAsFixed(2)
        : Converters.gramsToLbs(record.weight).toStringAsFixed(1);
    final weightUnit = units == Units.metric ? "KG" : "LBS";

    return AppModal(
      theme: theme,
      sizes: sizes,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weight Log",
            style: TextStyle(
              fontSize: sizes.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: sizes.spacing),
          Row(
            children: [
              Icon(Icons.monitor_weight, size: sizes.subtitleFontSize * 1.25),
              Text(
                " $weightValue $weightUnit",
                style: TextStyle(
                  fontSize: sizes.subtitleFontSize * 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (record.fatPercentage != null) ...[
                SizedBox(width: sizes.spacing * 2),
                Icon(
                  Icons.water_drop_outlined,
                  size: sizes.subtitleFontSize * 1.2,
                ),
                Text(
                  " ${Converters.intPercentToDouble(record.fatPercentage!).toStringAsFixed(2)} %",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: sizes.spacing),
          Row(
            children: [
              Icon(Icons.calendar_today, size: sizes.subtitleFontSize * 1.2),
              Text(
                " ${Formatters.formatRelativeDate(units, record.recordDate)}",
                style: TextStyle(
                  fontSize: sizes.fontSize,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.spacing),
          MutationButtons(
            padding: 0,
            theme: theme,
            sizes: sizes,
            isLoading: false,
            onEdit: () {
              Navigator.of(context).pop();
              showDialog(
                context: parentContext,
                builder: (context) => EditWeightRecordModal(
                  theme: theme,
                  sizes: sizes,
                  units: units,
                  record: record,
                ),
              );
            },
            onDelete: () {
              Navigator.of(context).pop();
              showDialog(
                context: parentContext,
                builder: (context) => ConfirmationDialog(
                  title: "Delete Weight Record",
                  content:
                      "Are you sure you want to delete this weight record?",
                  confirmLabel: "Delete",
                  isDestructive: true,
                  onConfirm: () async {
                    await context.read<WeightRecordCubit>().deleteWeightRecord(
                      record.id,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
