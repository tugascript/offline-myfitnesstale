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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/sizes/screen_size.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import '../../../core/widgets/not_found_list.dart';
import '../../view_models/states/workout_plan_record_state.dart';
import '../../view_models/workout_plan_record_cubit.dart';
import './single_workout_plan_record_list.dart';

class WorkoutPlanRecordHistory extends StatefulWidget {
  final ThemeData theme;
  final BreakPoint breakPoint;
  final DataDisplaySizesList sizes;
  final Units units;
  final int? workoutPlanId;
  final int? workoutPlanVersion;

  const WorkoutPlanRecordHistory({
    super.key,
    required this.theme,
    required this.breakPoint,
    required this.sizes,
    required this.units,
    this.workoutPlanId,
    this.workoutPlanVersion,
  });

  @override
  State<WorkoutPlanRecordHistory> createState() =>
      _WorkoutPlanRecordHistoryState();
}

class _WorkoutPlanRecordHistoryState extends State<WorkoutPlanRecordHistory> {
  static const int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<WorkoutPlanRecordCubit>();
    final dateRange = cubit.state.pagination.dateRange;
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: dateRange?.$1 ?? now.subtract(const Duration(days: 90)),
      end: dateRange?.$2 ?? now,
    );
    _scrollController.addListener(_onScroll);
    cubit.getWorkoutPlanRecords(
      workoutPlanId: widget.workoutPlanId,
      dateRange: (_dateRange.start, _dateRange.end),
      limit: _pageSize,
      offset: 0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final cubit = context.read<WorkoutPlanRecordCubit>();
    final state = cubit.state;
    final isNearBottom =
        _scrollController.offset >=
        _scrollController.position.maxScrollExtent * 0.9;
    final hasMore = state.planRecords.length < state.pagination.total;

    if (isNearBottom && hasMore && !state.isLoading) {
      cubit.getWorkoutPlanRecords(
        workoutPlanId: widget.workoutPlanId,
        progressStatus: state.pagination.progressStatus,
        dateRange: (_dateRange.start, _dateRange.end),
        limit: state.pagination.limit,
        offset: state.planRecords.length,
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
        await context.read<WorkoutPlanRecordCubit>().getWorkoutPlanRecords(
          workoutPlanId: widget.workoutPlanId,
          dateRange: (_dateRange.start, _dateRange.end),
          limit: _pageSize,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Records',
          style: TextStyle(
            fontSize: widget.sizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: widget.sizes.spacing),
        AppTextFormField(
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
        SizedBox(height: widget.sizes.spacing),
        BlocBuilder<WorkoutPlanRecordCubit, WorkoutPlanRecordState>(
          builder: (context, state) {
            if (!state.isLoading && state.planRecords.isEmpty) {
              return NotFoundList(
                height: widget.breakPoint.height / 3,
                sizes: widget.sizes,
                message: "No Plan History",
                icon: Icons.history,
              );
            }

            return SizedBox(
              height: widget.breakPoint.height / 2.35,
              child: SingleWorkoutPlanRecordList(
                sizes: widget.sizes,
                units: widget.units,
                isLoading: state.isLoading,
                planRecords: state.planRecords,
                pagination: state.pagination,
                workoutPlanId: widget.workoutPlanId,
                workoutPlanVersion: widget.workoutPlanVersion,
                scrollController: _scrollController,
              ),
            );
          },
        ),
      ],
    );
  }
}
