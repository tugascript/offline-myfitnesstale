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

  static String formatDateTime(Units unit, DateTime time) {
    switch (unit) {
      case Units.metric:
        return DateFormat("dd/MM/yyyy HH:mm").format(time);
      case Units.imperial:
        return DateFormat("MM/dd/yyyy HH:mm").format(time);
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

  static String formatTimer(int totalSecs) {
    final duration = Duration(seconds: totalSecs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final remainingSeconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  static String formatReps({
    required int minReps,
    required bool toMax,
    int? maxReps,
  }) {
    if (toMax) {
      return '$minReps-MAX';
    }

    if (maxReps != null && maxReps > minReps) {
      return '$minReps-$maxReps';
    }

    return '$minReps';
  }

  static String formatWeight(double weight) {
    String formatted = weight.toStringAsFixed(2);
    if (formatted.endsWith('.00')) {
      return formatted.substring(0, formatted.length - 3);
    }
    if (formatted.endsWith('0')) {
      return formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }
}
