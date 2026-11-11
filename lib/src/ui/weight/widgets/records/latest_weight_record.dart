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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/repositories/weight/dtos/weight_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/utils/converters.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../view_models/states/weight_record_state.dart';
import '../../view_models/weight_record_cubit.dart';
import './editor/create_weight_record_modal.dart';
import './editor/edit_weight_record_modal.dart';

class LatestWeightRecord extends StatefulWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  final Units units;

  const LatestWeightRecord({
    super.key,
    required this.sizes,
    required this.theme,
    required this.units,
  });

  @override
  State<LatestWeightRecord> createState() => _LatestWeightRecordState();
}

class _LatestWeightRecordState extends State<LatestWeightRecord> {
  @override
  void initState() {
    super.initState();
    context.read<WeightRecordCubit>().getLatestRecordedWeightRecord();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeightRecordCubit, WeightRecordState>(
      builder: (context, state) {
        if (!state.isLoading && state.latestWeightRecord == null) {
          return _EmptyWeightRecord(sizes: widget.sizes, theme: widget.theme);
        }

        return _LatestWeightRecord(
          sizes: widget.sizes,
          theme: widget.theme,
          units: widget.units,
          isLoading: state.isLoading,
          weightRecord: state.latestWeightRecord,
          onEdit: () {
            if (state.latestWeightRecord != null) {
              showDialog(
                context: context,
                builder: (context) => EditWeightRecordModal(
                  theme: widget.theme,
                  sizes: widget.sizes,
                  units: widget.units,
                  record: state.latestWeightRecord!,
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _EmptyWeightRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;

  const _EmptyWeightRecord({required this.sizes, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) =>
                  CreateWeightRecordModal(theme: theme, sizes: sizes),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: sizes.padding * 2,
              horizontal: sizes.padding,
            ),
            child: Column(
              children: [
                Icon(Icons.monitor_weight, size: sizes.titleFontSize * 2),
                SizedBox(height: sizes.spacing),
                Text(
                  "No weight logs",
                  style: TextStyle(
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[200]
                        : Colors.grey[800],
                  ),
                ),
                SizedBox(height: sizes.spacing),
                Text(
                  "Tap to add your first weight log",
                  style: TextStyle(
                    fontSize: sizes.subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LatestWeightRecord extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final Units units;

  final bool isLoading;
  final WeightRecordDto? weightRecord;
  final VoidCallback onEdit;

  const _LatestWeightRecord({
    required this.sizes,
    required this.theme,
    required this.units,
    required this.isLoading,
    required this.weightRecord,
    required this.onEdit,
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
          child: Skeletonizer(
            enabled: isLoading || weightRecord == null,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Latest Weight Log",
                      style: TextStyle(
                        fontSize: sizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      key: const ValueKey('latest-weight-record-edit'),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: sizes.titleFontSize * 1.2,
                        color: theme.colorScheme.brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      onPressed: onEdit,
                    ),
                  ],
                ),
                SizedBox(height: sizes.spacing),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.monitor_weight,
                          size: sizes.subtitleFontSize * 1.2,
                        ),
                        Text(
                          _displayWeight(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: sizes.subtitleFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (weightRecord != null &&
                            weightRecord?.fatPercentage != null) ...[
                          SizedBox(width: sizes.spacing * 2),
                          Icon(
                            Icons.water_drop_outlined,
                            size: sizes.subtitleFontSize * 1.2,
                          ),
                          Text(
                            " ${Converters.intPercentToDouble(weightRecord!.fatPercentage!).toStringAsFixed(2)}%",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: sizes.subtitleFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: sizes.spacing),
                    Row(
                      children: [
                        SizedBox(width: sizes.padding * 2.5),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: sizes.subtitleFontSize * 1.2,
                              ),
                              Text(
                                " ${Formatters.formatRelativeDate(units, weightRecord?.recordDate ?? DateTime.now())}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: sizes.subtitleFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('latest-weight-record-delete'),
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.delete,
                            size: sizes.titleFontSize,
                            color:
                                theme.colorScheme.brightness == Brightness.dark
                                ? Colors.red[400]
                                : Colors.red[600],
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ConfirmationDialog(
                                title: 'Delete Weight Log',
                                content: 'Are you sure you want to delete this weight log? This action cannot be undone.',
                                onConfirm: () async {
                                  if (weightRecord != null) {
                                    await context
                                        .read<WeightRecordCubit>()
                                        .deleteWeightRecord(weightRecord!.id);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _displayWeight() {
    final int weight = weightRecord?.weight ?? 0;
    switch (units) {
      case Units.metric:
        return "${Converters.gramsToKg(weight).toStringAsFixed(2)}KG";
      case Units.imperial:
        return "${Converters.gramsToLbs(weight).toStringAsFixed(2)}LBS";
    }
  }
}
