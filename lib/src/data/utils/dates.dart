sealed class DateUtilities {
  static int getNowUtcUnix() {
    return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  }

  static int getDateUnix(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
  }

  static DateTime getDateFromUnix(int unix) {
    return DateTime.fromMillisecondsSinceEpoch(
      unix * 1000,
      isUtc: true,
    ).toLocal();
  }

  static int getNumericDate(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  static DateTime convertNumericDate(int date) {
    final int year = date ~/ 10000;
    final int month = (date ~/ 100) % 100;
    final int day = date % 100;
    return DateTime.utc(year, month, day);
  }
}
