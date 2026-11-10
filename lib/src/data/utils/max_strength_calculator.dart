sealed class MaxStrengthCalculator {
  static int _epley(int reps, int weight) {
    return (weight * (1 + (reps / 30))).round();
  }

  static int _brycki(int reps, int weight) {
    return (weight * (36.0 / (37.0 - reps))).round();
  }

  static int calculateMaxStrength(int reps, int weight) {
    if (reps == 0 || weight == 0 || reps > 10) {
      return 0;
    }

    if (reps == 1) {
      return weight;
    }
    if (reps <= 3) {
      return _brycki(reps, weight);
    }

    return _epley(reps, weight);
  }
}
