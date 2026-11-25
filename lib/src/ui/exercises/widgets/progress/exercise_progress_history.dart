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
import 'package:material_ui/material_ui.dart';

import '../../../../data/repositories/exercises/dtos/exercise_record_dto.dart';
import '../../../../data/utils/enums.dart';
import '../../../core/sizes/data_display_sizes.dart';
import '../../../core/sizes/screen_size.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/layout/app_text_form_field.dart';
import '../../../core/widgets/not_found_list.dart';
import '../../view_models/exercise_record_cubit.dart';
import '../../view_models/states/exercise_record_state.dart';
import './exercise_progress_error_card.dart';
import './exercise_progress_records_list.dart';

class ExerciseProgressHistory extends StatefulWidget {
  static const int pageSize = 20;

  final ThemeData theme;
  final BreakPoint breakPoint;
  final DataDisplaySizesList sizes;
  final Units units;
  final DateTimeRange dateRange;
  final ValueChanged<DateTimeRange> onDateRangeChanged;
  final Future<void> Function(int exerciseId) onOpenExerciseRecords;

  const ExerciseProgressHistory({
    super.key,
    required this.theme,
    required this.breakPoint,
    required this.sizes,
    required this.units,
    required this.dateRange,
    required this.onDateRangeChanged,
    required this.onOpenExerciseRecords,
  });

  @override
  State<ExerciseProgressHistory> createState() =>
      _ExerciseProgressHistoryState();
}

class _ExerciseProgressHistoryState extends State<ExerciseProgressHistory> {
  final ScrollController _scrollController = ScrollController();
  bool _refetchTriggered = false;
  bool _waitingForPostFrame = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ExerciseRecordCubit>().getExerciseRecords(
      dateRange: (widget.dateRange.start, widget.dateRange.end),
      limit: ExerciseProgressHistory.pageSize,
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

    final cubit = context.read<ExerciseRecordCubit>();
    final state = cubit.state;
    final isNearBottom =
        _scrollController.offset >=
        _scrollController.position.maxScrollExtent * 0.9;
    final hasMore = state.exerciseRecords.length < state.recordPagination.total;

    if (isNearBottom &&
        hasMore &&
        !state.isRecordsLoading &&
        state.recordsError == null) {
      cubit.getExerciseRecords(
        dateRange: (widget.dateRange.start, widget.dateRange.end),
        limit: state.recordPagination.limit,
        offset: state.exerciseRecords.length,
      );
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: widget.dateRange,
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

    if (picked != null && picked != widget.dateRange) {
      widget.onDateRangeChanged(picked);
      if (mounted) {
        await context.read<ExerciseRecordCubit>().getExerciseRecords(
          dateRange: (picked.start, picked.end),
          limit: ExerciseProgressHistory.pageSize,
          offset: 0,
        );
      }
    }
  }

  void _retryLoad() {
    _refetchTriggered = false;
    context.read<ExerciseRecordCubit>().getExerciseRecords(
      dateRange: (widget.dateRange.start, widget.dateRange.end),
      limit: ExerciseProgressHistory.pageSize,
      offset: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateRangeText =
        "${Formatters.formatDate(widget.units, widget.dateRange.start)} - ${Formatters.formatDate(widget.units, widget.dateRange.end)}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise Records',
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
        BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
          builder: (context, state) {
            final isLoading = state.isRecordsLoading;
            final isScoped = state.recordPagination.exerciseId != null;
            final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
            if (!isScoped) {
              _refetchTriggered = false;
              _waitingForPostFrame = false;
            } else if (!isLoading && isCurrentRoute && !_refetchTriggered) {
              _refetchTriggered = true;
              _waitingForPostFrame = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _waitingForPostFrame = false;
                context.read<ExerciseRecordCubit>().getExerciseRecords(
                  dateRange: (widget.dateRange.start, widget.dateRange.end),
                  limit: ExerciseProgressHistory.pageSize,
                  offset: 0,
                );
              });
            }

            final records = !isScoped
                ? state.exerciseRecords
                : const <ExerciseRecordDto>[];
            final effectiveLoading =
                isLoading ||
                _waitingForPostFrame ||
                (isScoped && state.recordsError == null);
            if (!effectiveLoading &&
                state.recordsError != null &&
                (isScoped || records.isEmpty)) {
              return ExerciseProgressErrorCard(
                theme: widget.theme,
                sizes: widget.sizes,
                message: state.recordsError!.description,
                onRetry: _retryLoad,
              );
            }
            if (!effectiveLoading && records.isEmpty) {
              return NotFoundList(
                height: widget.breakPoint.height / 3,
                sizes: widget.sizes,
                message: "Empty history",
                icon: Icons.history,
              );
            }

            return SizedBox(
              height: widget.breakPoint.height / 2.35,
              child: ExerciseProgressRecordsList(
                sizes: widget.sizes,
                units: widget.units,
                isLoading: effectiveLoading,
                exerciseRecords: records,
                pagination: state.recordPagination,
                scrollController: _scrollController,
                onTapExercise: widget.onOpenExerciseRecords,
                loadMoreError: !isScoped
                    ? state.recordsError?.description
                    : null,
                onRetryLoadMore: () {
                  context.read<ExerciseRecordCubit>().getExerciseRecords(
                    dateRange: (widget.dateRange.start, widget.dateRange.end),
                    limit: state.recordPagination.limit,
                    offset: state.exerciseRecords.length,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
