final class Converters {
  Converters._internal();
  static final Converters _instance = Converters._internal();
  factory Converters() => _instance;

  (int, int) cmToFeetAndInches(int cm) {
    final double totalInches = cm / 2.54;
    final int feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return (feet, inches.round());
  }

  int feetAndInchesToCm(int feet, int inches) {
    return (((feet * 12) + inches) * 2.54).round();
  }

  String formatImperialHeight(int cm) {
    final (int feet, int inches) = cmToFeetAndInches(cm);
    return "$feet' $inches\"";
  }

  double gramsToKg(int grams) {
    return (grams / 1000);
  }

  int kgToGrams(double kg) {
    return (kg * 1000).round();
  }

  double gramsToLbs(int grams) {
    return (grams / 453.592);
  }

  String formatImperialWeight(int grams) {
    final double lbs = gramsToLbs(grams);
    return "${lbs.toStringAsFixed(1)} lbs";
  }

  String formatMetricWeight(int grams) {
    final double kg = gramsToKg(grams);
    return "${kg.toStringAsFixed(2)} kg";
  }
}
