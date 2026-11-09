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

  static String formatRelativeDate(Units unit, DateTime date, {DateTime? now}) {
    final reference = (now ?? DateTime.now()).toLocal();
    final localDate = date.toLocal();
    final today = DateTime.utc(reference.year, reference.month, reference.day);
    final targetDay = DateTime.utc(
      localDate.year,
      localDate.month,
      localDate.day,
    );
    final days = today.difference(targetDay).inDays;

    if (days < 0 || days >= 30) {
      return formatDate(unit, date);
    }
    if (days == 0) {
      return 'Today';
    }
    if (days == 1) {
      return 'Yesterday';
    }
    if (days < 7) {
      return '$days days ago';
    }
    final weeks = days ~/ 7;
    if (weeks == 1) {
      return '1 week ago';
    }
    return '$weeks weeks ago';
  }

  static String formatDateTime(Units unit, DateTime time) {
    switch (unit) {
      case Units.metric:
        return DateFormat("dd/MM/yyyy HH:mm").format(time);
      case Units.imperial:
        return DateFormat("MM/dd/yyyy HH:mm").format(time);
    }
  }

  static String formatRelativeDateTime(
    Units unit,
    DateTime time, {
    DateTime? now,
  }) {
    return '${formatRelativeDate(unit, time, now: now)} ${formatTime(time)}';
  }

  static String formatTime(DateTime time) {
    return DateFormat("HH:mm").format(time);
  }

  static String formatDateTimeRange(
    Units unit,
    DateTime start,
    DateTime? end, {
    DateTime? now,
  }) {
    final startStr = formatRelativeDateTime(unit, start, now: now);
    if (end == null) {
      return startStr;
    }

    final localStart = start.toLocal();
    final localEnd = end.toLocal();
    final isSameDay =
        localStart.year == localEnd.year &&
        localStart.month == localEnd.month &&
        localStart.day == localEnd.day;

    if (isSameDay) {
      return '$startStr - ${formatTime(end)}';
    }

    return '$startStr - ${formatRelativeDateTime(unit, end, now: now)}';
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
