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

import '../../../../../data/repositories/weight/dtos/weight_record_dto.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/utils/converters.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/layout/app_modal.dart';
import '../../../../core/widgets/mutation_buttons.dart';
import '../../../view_models/weight_record_cubit.dart';
import './edit_weight_record_modal.dart';

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
