import 'package:intl/intl.dart';

import '../models/enums.dart';

sealed class Formatters {
  static String formatDate(Units unit, DateTime date) {
    switch (unit) {
      case Units.metric:
        return DateFormat("dd/MM/yyyy").format(date);
      case Units.imperial:
        return DateFormat("MM/dd/yyyy").format(date);
    }
  }

  static String formatDuration(int totalSecs) {
    final duration = Duration(seconds: totalSecs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final remainingSeconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }
}
