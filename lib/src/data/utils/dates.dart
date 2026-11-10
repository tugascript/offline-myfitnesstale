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
