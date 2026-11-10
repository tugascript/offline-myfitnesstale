// Copyright (C) 2026 afonsobarracha
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
import 'package:skeletonizer/skeletonizer.dart';

import '../../view_models/weight_record_cubit.dart';
import '../../../../data/utils/enums.dart';
import '../../../../data/repositories/weight/dtos/weight_record_dto.dart';
import '../../../core/utils/converters.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import './editor/edit_weight_record_modal.dart';

class WeightRecordsList extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final Units units;

  final List<WeightRecordDto> records;
  final bool isLoading;

  const WeightRecordsList({
    super.key,
    required this.theme,
    required this.sizes,
    required this.units,
    required this.records,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading && records.isEmpty,
      child: ListView.builder(
        itemCount: isLoading && records.isEmpty ? 2 : records.length,
        itemBuilder: (context, index) {
          if (isLoading && records.isEmpty) {
            return _WeightRecordCard(
              theme: theme,
              record: WeightRecordDto.empty(),
              units: units,
              sizes: sizes,
            );
          }

          final record = records[index];
          return _WeightRecordCard(
            theme: theme,
            record: record,
            units: units,
            sizes: sizes,
          );
        },
      ),
    );
  }
}

class _WeightRecordCard extends StatelessWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;

  final Units units;
  final WeightRecordDto record;

  const _WeightRecordCard({
    required this.theme,
    required this.record,
    required this.units,
    required this.sizes,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = theme.colorScheme.brightness == Brightness.dark;
    final greyColor = isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade600;
    final redColor = isDarkTheme ? Colors.red.shade400 : Colors.red.shade600;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(vertical: sizes.margins / 2),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monitor_weight, size: sizes.fontSize * 1.2),
                Text(
                  " ${_displayWeight()} ${units == Units.imperial ? "LBS" : "KG"}",
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (record.fatPercentage != null) ...[
                  SizedBox(width: sizes.spacing),
                  Icon(Icons.water_drop_outlined, size: sizes.fontSize * 1.2),
                  Text(
                    _displayBodyFatPercentage(),
                    style: TextStyle(
                      fontSize: sizes.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: sizes.fontSize * 1.2),
                Text(
                  " ${Formatters.formatRelativeDate(units, record.recordDate)}",
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => EditWeightRecordModal(
                        theme: theme,
                        sizes: sizes,
                        units: units,
                        record: record,
                      ),
                    );
                  },
                  icon: Icon(Icons.edit),
                  color: greyColor,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: "Delete Weight Record",
                        content: "Are you sure you want to delete this weight record?",
                        confirmLabel: "Delete",
                        isDestructive: true,
                        onConfirm: () async {
                          await context
                              .read<WeightRecordCubit>()
                              .deleteWeightRecord(record.id);
                        },
                      ),
                    );
                  },
                  icon: Icon(Icons.delete),
                  color: redColor,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _displayWeight() {
    if (units == Units.imperial) {
      return Converters.gramsToLbs(record.weight).toStringAsFixed(2);
    }

    return Converters.gramsToKg(record.weight).toStringAsFixed(2);
  }

  String _displayBodyFatPercentage() {
    if (record.fatPercentage == null) {
      return "";
    }

    return "${Converters.intPercentToDouble(record.fatPercentage!).toStringAsFixed(2)}%";
  }
}
