import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubits/macro_tracking_cubit.dart';
import '../../cubits/states/macro_tracking_state.dart';
import '../../models/utilities.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class MacroTrackerWeekWidget extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final ThemeData theme;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  const MacroTrackerWeekWidget(
      {required this.theme,
      super.key,
      required this.sizes,
      required this.selectedDate,
      required this.onSelectDate});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
      builder: (context, state) {
        final logs = state.rangeLogs;
        final startOfWeek =
            selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

        return ListView.separated(
          itemCount: 7,
          separatorBuilder: (_, __) => SizedBox(height: sizes.spacing / 2),
          itemBuilder: (context, index) {
            final dayDate = startOfWeek.add(Duration(days: index));
            final numDate = DateUtilities.getNumericDate(dayDate);
            final dayLog = logs.where((l) => l.date == numDate);
            final log = dayLog.isNotEmpty ? dayLog.first : null;

            final isSelectedDay = dayDate.year == selectedDate.year &&
                dayDate.month == selectedDate.month &&
                dayDate.day == selectedDate.day;

            return Card(
              color: isSelectedDay
                  ? theme.primaryColor.withValues(alpha: 0.1)
                  : null,
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(
                  DateFormat('EEEE, MMM d').format(dayDate),
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  log != null
                      ? '${log.totalCalories} kcal • P: ${log.totalProtein}g C: ${log.totalCarbs}g F: ${log.totalFat}g'
                      : 'No foods logged',
                  style: TextStyle(
                    fontSize: sizes.fontSize * 0.85,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Icon(Icons.chevron_right, size: sizes.buttonIconSize),
                onTap: () {
                  onSelectDate(dayDate);
                },
              ),
            );
          },
        );
      },
    );
  }
}
