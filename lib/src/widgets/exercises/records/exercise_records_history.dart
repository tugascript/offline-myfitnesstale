import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/exercise_record_cubit.dart';
import '../../../cubits/states/exercise_record_state.dart';
import '../../../models/enums.dart';
import '../../../services/dtos/exercise_dto.dart';
import '../../../utilities/formatters.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../../utilities/sizes/screen_size.dart';
import '../../common/icons_switch.dart';
import '../../common/not_found_list.dart';
import '../../layout/app_text_form_field.dart';
import 'exercise_records_chart.dart';
import 'exercise_records_list.dart';

class ExerciseRecordsHistory extends StatefulWidget {
  final ThemeData theme;
  final BreakPoint breakPoint;
  final DataDisplaySizesList sizes;
  final Units units;

  final ExerciseDto exercise;

  const ExerciseRecordsHistory({
    super.key,
    required this.theme,
    required this.breakPoint,
    required this.sizes,
    required this.units,
    required this.exercise,
  });

  @override
  State<ExerciseRecordsHistory> createState() => _ExerciseRecordsHistoryState();
}

class _ExerciseRecordsHistoryState extends State<ExerciseRecordsHistory> {
  bool _showList = false;
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<ExerciseRecordCubit>();
    final dateRange = cubit.state.recordPagination.dateRange;
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: dateRange?.$1 ?? now.subtract(const Duration(days: 90)),
      end: dateRange?.$2 ?? now,
    );
    cubit.getExerciseRecords(
      dateRange: (_dateRange.start, _dateRange.end),
      exerciseId: widget.exercise.id,
      limit: 1000,
      offset: 0,
    );
  }

  Future<void> _selectDateRange() async {
    final DateTime now = DateTime.now();
    final DateTime oneYearAgo = now.subtract(const Duration(days: 365));
    final DateTime firstDate =
        DateTime(2025).isAfter(oneYearAgo) ? DateTime(2025) : oneYearAgo;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
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

    // Limit: Selected range must be <= 365 days
    if (picked != null && picked != _dateRange) {
      final difference = picked.end.difference(picked.start).inDays;
      if (difference > 365) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select a range of one year or less.'),
              backgroundColor: widget.theme.colorScheme.error,
            ),
          );
        }
        return;
      }

      setState(() {
        _dateRange = picked;
      });
      if (mounted) {
        await context.read<ExerciseRecordCubit>().getExerciseRecords(
              exerciseId: widget.exercise.id,
              dateRange: (_dateRange.start, _dateRange.end),
              limit: 1000,
              offset: 0,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateRangeText = "${Formatters.formatDate(
      widget.units,
      _dateRange.start,
    )} - ${Formatters.formatDate(
      widget.units,
      _dateRange.end,
    )}";
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
                "Records History",
                style: TextStyle(
                  fontSize: widget.sizes.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
              IconsSwitch(
                theme: widget.theme,
                offIcon: Icons.show_chart,
                onIcon: Icons.list,
                switchOn: _showList,
                spacing: widget.sizes.spacing / 2,
                switchPadding: widget.sizes.padding / 4,
                thumbSize: widget.sizes.subtitleFontSize * 1.1,
                iconSize: widget.sizes.titleFontSize,
                onChanged: (bool value) {
                  setState(() {
                    _showList = value;
                  });
                },
              ),
            ],
          ),
        ),
        SizedBox(height: widget.sizes.spacing),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.sizes.spacing / 3,
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
        BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
          builder: (context, state) {
            if (!state.isLoading && state.exerciseRecords.isEmpty) {
              return NotFoundList(
                height: widget.breakPoint.height / 3,
                sizes: widget.sizes,
                message: "Empty history",
                icon: _showList ? Icons.history : Icons.auto_graph,
              );
            }

            return SizedBox(
              height: widget.breakPoint.height / 2.375,
              width: double.infinity,
              child: _showList
                  ? ExerciseRecordsList(
                      theme: widget.theme,
                      sizes: widget.sizes,
                      units: widget.units,
                      exercise: widget.exercise,
                      records: state.exerciseRecords,
                      isLoading: state.isLoading,
                    )
                  : Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.sizes.padding,
                          vertical: widget.sizes.padding * 2,
                        ),
                        child: ExerciseRecordsChart(
                          exercise: widget.exercise,
                          theme: widget.theme,
                          sizes: widget.sizes,
                          records: state.exerciseRecords,
                          units: widget.units,
                          isLoading: state.isLoading,
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
