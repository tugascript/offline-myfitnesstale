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
}
