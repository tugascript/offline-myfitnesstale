import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../cubits/states/weight_record_state.dart';
import '../../../cubits/weight_record_cubit.dart';
import '../../../models/enums.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../../utilities/sizes/screen_size.dart';
import '../../common/not_found_list.dart';
import '../../layout/app_text_form_field.dart';
import '../../layout/sharp_switch.dart';
import 'weight_records_chart.dart';
import 'weight_records_list.dart';

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
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 90)),
      end: now,
    );

    final cubit = context.read<WeightRecordCubit>();
    if (cubit.state.weightRecords.isEmpty) {
      cubit.getWeightRecords(
        dateRange: (_dateRange.start, _dateRange.end),
      );
    }
  }

  String _formatDate(DateTime date) {
    switch (widget.units) {
      case Units.metric:
        return DateFormat("dd/MM/yyyy").format(date);
      case Units.imperial:
        return DateFormat("MM/dd/yyyy").format(date);
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        final bodyLarge = widget.theme.textTheme.bodyLarge;
        return Theme(
          data: widget.theme.copyWith(
            textTheme: widget.theme.textTheme.copyWith(
              displayLarge: bodyLarge,
              displayMedium: bodyLarge,
              displaySmall: bodyLarge,
              headlineLarge: bodyLarge,
              headlineMedium: bodyLarge,
              headlineSmall: bodyLarge,
              titleLarge: bodyLarge,
              titleMedium: bodyLarge,
            ),
            datePickerTheme: widget.theme.datePickerTheme.copyWith(
              rangePickerHeaderHeadlineStyle: bodyLarge,
              headerHeadlineStyle: bodyLarge,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      if (mounted) {
        await context.read<WeightRecordCubit>().getWeightRecords(
          dateRange: (_dateRange.start, _dateRange.end),
          limit: 100,
          offset: 0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateRangeText =
        "${_formatDate(_dateRange.start)} - ${_formatDate(_dateRange.end)}";

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
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.sizes.spacing / 2,
          ),
          child: AppTextFormField(
            theme: widget.theme,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding * 2,
            isLoading: false,
            readOnly: true,
            hintText: dateRangeText,
            suffixIconConstraints: BoxConstraints(
              minWidth: widget.sizes.subtitleFontSize * 4,
              minHeight: widget.sizes.subtitleFontSize * 1.5,
            ),
            suffixIcon: Icon(
              Icons.date_range,
              color: widget.theme.colorScheme.primary,
              size: widget.sizes.subtitleFontSize * 2,
            ),
            onTap: _selectDateRange,
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
              height: widget.breakPoint.height / 2.25,
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
