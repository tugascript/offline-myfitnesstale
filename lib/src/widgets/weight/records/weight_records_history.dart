import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/states/weight_record_state.dart';
import '../../../cubits/weight_record_cubit.dart';
import '../../../models/enums.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../../utilities/sizes/screen_size.dart';
import '../../common/not_found_list.dart';
import '../../layout/sharp_switch.dart';
import 'weight_records_chart.dart';
import 'weight_records_list.dart';

// TODO: add time period selection
class WeightRecordsHistory extends StatefulWidget {
  final ThemeData theme;
  final BreakPoint breakPoint;
  final DataDisplaySizesList sizes;
  final Units units;

  const WeightRecordsHistory({
    super.key,
    required this.theme,
    required this.breakPoint,
    required this.sizes,
    required this.units,
  });

  @override
  State<WeightRecordsHistory> createState() => _WeightRecordsHistoryState();
}

class _WeightRecordsHistoryState extends State<WeightRecordsHistory> {
  bool _showList = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<WeightRecordCubit>();
    if (cubit.state.weightRecords.isEmpty) {
      cubit.getWeightRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.sizes.spacing / 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Record History",
                style: TextStyle(
                  fontSize: widget.sizes.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.show_chart,
                    color: _showList
                        ? widget.theme.colorScheme.onSurfaceVariant
                        : widget.theme.colorScheme.primary,
                  ),
                  SizedBox(
                    width: widget.sizes.spacing / 2,
                  ),
                  SharpSwitch(
                    value: _showList,
                    onChanged: (bool value) {
                      setState(() {
                        _showList = value;
                      });
                    },
                    padding: EdgeInsets.all(widget.sizes.padding / 4),
                    thumbSize: widget.sizes.subtitleFontSize * 1.1,
                  ),
                  SizedBox(
                    width: widget.sizes.spacing / 2,
                  ),
                  Icon(
                    Icons.list,
                    color: _showList
                        ? widget.theme.colorScheme.primary
                        : widget.theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              )
            ],
          ),
        ),
        SizedBox(height: widget.sizes.spacing),
        BlocBuilder<WeightRecordCubit, WeightRecordState>(
          builder: (context, state) {
            if (!state.isLoading && state.weightRecords.isEmpty) {
              return NotFoundList(
                height: widget.breakPoint.height / 3,
                sizes: widget.sizes,
                message: "Empty history",
                icon: _showList ? Icons.history : Icons.auto_graph,
              );
            }

            return SizedBox(
              height: widget.breakPoint.height / 2.5,
              width: double.infinity,
              child: _showList
                  ? WeightRecordsList(
                      theme: widget.theme,
                      sizes: widget.sizes,
                      units: widget.units,
                      records: state.weightRecords,
                      isLoading: state.isLoading,
                    )
                  : Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.sizes.padding,
                          vertical: widget.sizes.padding * 2,
                        ),
                        child: WeightRecordsChart(
                          records: state.weightRecords.reversed.toList(),
                          units: widget.units,
                          labelSize: widget.sizes.fontSize,
                          theme: widget.theme,
                          sizes: widget.sizes,
                        ),
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }
}
