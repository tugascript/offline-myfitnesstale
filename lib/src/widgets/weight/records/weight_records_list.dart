import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../cubits/weight_record_cubit.dart';
import '../../../models/enums.dart';
import '../../../services/dtos/weight_record_dto.dart';
import '../../../utilities/converters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/confirmation_dialog.dart';
import 'editor/edit_weight_record_modal.dart';

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
      margin: EdgeInsets.symmetric(
        vertical: sizes.margins / 2,
      ),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.monitor_weight,
                  size: sizes.fontSize * 1.2,
                ),
                Text(
                  " ${_displayWeight()} ${units == Units.imperial ? "LBS" : "KG"}",
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: sizes.fontSize * 1.2,
                ),
                Text(
                  " ${_formatDate()}",
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
                        content:
                            "Are you sure you want to delete this weight record?",
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
                )
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

  String _formatDate() {
    switch (units) {
      case Units.metric:
        return DateFormat("dd/MM/yyyy").format(record.recordDate);
      case Units.imperial:
        return DateFormat("MM/dd/yyyy").format(record.recordDate);
    }
  }
}
