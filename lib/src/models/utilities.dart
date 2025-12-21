sealed class DateUtilities {
  static int getNowUtcUnix() {
    return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  }

  static int getNumericDate(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
  }
}

sealed class MaxStrengthCalculator {
  static int _epley(int reps, int weight) {
    return (weight * (1 + 30 / reps)).round();
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

class WhereBuilder {
  final List<String> _where = [];
  final List<Object?> _args = [];

  String? get where => _where.isEmpty ? null : _where.join(' AND ');

  List<Object?>? get args => _args.isEmpty ? null : _args;

  void add(String condition, [Object? arg]) {
    _where.add(condition);

    if (arg != null) {
      _args.add(arg);
    }
  }
}
