import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../cubits/states/weight_record_state.dart';
import '../../../cubits/weight_record_cubit.dart';
import '../../../models/enums.dart';
import '../../../services/dtos/weight_record_dto.dart';
import '../../../utilities/converters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../common/confirmation_dialog.dart';
import 'editor/create_weight_record_modal.dart';
import 'editor/edit_weight_record_modal.dart';

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
          return _EmptyWeightRecord(
            sizes: widget.sizes,
            theme: widget.theme,
          );
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

  const _EmptyWeightRecord({
    required this.sizes,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => CreateWeightRecordModal(
                theme: theme,
                sizes: sizes,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: sizes.padding * 2,
              horizontal: sizes.padding,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.monitor_weight,
                  size: sizes.titleFontSize * 2,
                ),
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
                          units == Units.imperial
                              ? " ${Converters.gramsToLbs(
                                  weightRecord?.weight ?? 0,
                                ).toStringAsFixed(2)} LBS"
                              : " ${Converters.gramsToKg(
                                  weightRecord?.weight ?? 0,
                                ).toStringAsFixed(2)} KG",
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
                            " ${Converters.intPercentToDouble(weightRecord!.fatPercentage!).toStringAsFixed(2)} %",
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
                                " ${_formatDate()}",
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
                                content:
                                    'Are you sure you want to delete this weight log? This action cannot be undone.',
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
                        )
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

  String _formatDate() {
    final date = weightRecord?.recordDate ?? DateTime.now();

    switch (units) {
      case Units.metric:
        return DateFormat("dd/MM/yyyy").format(date);
      case Units.imperial:
        return DateFormat("MM/dd/yyyy").format(date);
    }
  }
}
