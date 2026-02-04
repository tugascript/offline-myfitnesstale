sealed class Converters {
  static (int, int) cmToFeetAndInches(int cm) {
    final double totalInches = cm / 2.54;
    final int feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return (feet, inches.round());
  }

  static int feetAndInchesToCm(int feet, int inches) {
    return (((feet * 12) + inches) * 2.54).round();
  }

  static String formatImperialHeight(int cm) {
    final (int feet, int inches) = cmToFeetAndInches(cm);
    return "$feet' $inches\"";
  }

  static double gramsToKg(int grams) {
    return (grams / 1000);
  }

  static int kgToGrams(double kg) {
    return (kg * 1000).round();
  }

  static double gramsToLbs(int grams) {
    return (grams / 453.592);
  }

  static String formatImperialWeight(int grams) {
    final double lbs = gramsToLbs(grams);
    return "${lbs.toStringAsFixed(1)} lbs";
  }

  static String formatMetricWeight(int grams) {
    final double kg = gramsToKg(grams);
    return "${kg.toStringAsFixed(2)} kg";
  }

  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return "${seconds}s";
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) {
      return "${minutes}m";
    }
    return "${minutes}m ${remainingSeconds}s";
  }

  static String formatDate(DateTime timestamp, {bool imperial = false}) {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year.toString().padLeft(4, '0');

    if (imperial) {
      return "$month/$day/$year";
    }

    return "$day/$month/$year";
  }

  static String capitalizeString(String str) {
    return str
        .split(RegExp(r'[ _]'))
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(" ");
  }
}
