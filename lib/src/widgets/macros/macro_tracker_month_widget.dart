import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubits/macro_tracking_cubit.dart';
import '../../cubits/states/macro_tracking_state.dart';
import '../../models/utilities.dart';
import '../../utilities/sizes/data_display_sizes.dart';

class MacroTrackerMonthWidget extends StatelessWidget {
  final DataDisplaySizesList sizes;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  const MacroTrackerMonthWidget(
      {super.key,
      required this.sizes,
      required this.selectedDate,
      required this.onSelectDate});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<MacroTrackingCubit, MacroTrackingState>(
      builder: (context, state) {
        final logs = state.rangeLogs;
        final daysInMonth =
            DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

        return ListView.separated(
          itemCount: daysInMonth,
          separatorBuilder: (_, __) => SizedBox(height: sizes.spacing / 2),
          itemBuilder: (context, index) {
            final dayDate =
                DateTime(selectedDate.year, selectedDate.month, index + 1);
            final numDate = DateUtilities.getNumericDate(dayDate);
            final dayLog = logs.where((l) => l.date == numDate);
            final log = dayLog.isNotEmpty ? dayLog.first : null;

            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(
                  DateFormat('EEE, MMM d').format(dayDate),
                  style: TextStyle(fontSize: sizes.fontSize),
                ),
                trailing: Text(
                  log != null ? '${log.totalCalories} kcal' : '-',
                  style: TextStyle(
                    fontSize: sizes.fontSize,
                    fontWeight: FontWeight.bold,
                    color: log != null ? theme.primaryColor : Colors.grey,
                  ),
                ),
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
