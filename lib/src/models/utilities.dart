import 'enums.dart';

sealed class DateUtilities {
  static int getNowUtcUnix() {
    return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  }

  static int getDateUnix(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
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

enum _WhereUnion {
  and('AND'),
  or('OR');

  final String value;

  const _WhereUnion(this.value);
}

class _WhereStatement {
  final String condition;
  final _WhereUnion union;

  const _WhereStatement(this.condition, this.union);
}

class WhereBuilder {
  final List<_WhereStatement> _where = [];
  final List<Object?> _args = [];

  String? get where {
    if (_where.isEmpty) {
      return null;
    }
    if (_where.length == 1) {
      return _where.first.condition;
    }

    return [
      _where.first.condition,
      ..._where.skip(1).map((e) => '${e.union.value} (${e.condition})')
    ].join(' ');
  }

  List<Object?>? get args => _args.isEmpty ? null : _args;

  void and(String condition, [Object? arg]) {
    _where.add(_WhereStatement(condition, _WhereUnion.and));

    if (arg != null) {
      _args.add(arg);
    }
  }

  void or(String condition, [Object? arg]) {
    _where.add(_WhereStatement(condition, _WhereUnion.or));

    if (arg != null) {
      _args.add(arg);
    }
  }
}

sealed class EnumDisplayNames {
  static String getMuscleGroupDisplayName(MuscleGroup? group) {
    switch (group) {
      case MuscleGroup.full:
        return 'Full Body';
      case MuscleGroup.push:
        return 'Push';
      case MuscleGroup.pull:
        return 'Pull';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.core:
        return 'Core';
      case null:
        return 'Unknown';
    }
  }

  static String getMuscleDisplayName(Muscle? muscle) {
    switch (muscle) {
      case Muscle.chest:
        return 'Chest';
      case Muscle.upperChest:
        return 'Upper Chest';
      case Muscle.lowerChest:
        return 'Lower Chest';
      case Muscle.innerChest:
        return 'Inner Chest';
      case Muscle.shoulders:
        return 'Shoulders';
      case Muscle.frontDelts:
        return 'Front Delts';
      case Muscle.sideDelts:
        return 'Side Delts';
      case Muscle.rearDelts:
        return 'Rear Delts';
      case Muscle.triceps:
        return 'Triceps';
      case Muscle.neck:
        return 'Neck';
      case Muscle.trapezius:
        return 'Trapezius';
      case Muscle.upperTrapezius:
        return 'Upper Trapezius';
      case Muscle.middleTrapezius:
        return 'Middle Trapezius';
      case Muscle.lowerTrapezius:
        return 'Lower Trapezius';
      case Muscle.rhomboids:
        return 'Rhomboids';
      case Muscle.lats:
        return 'Lats';
      case Muscle.biceps:
        return 'Biceps';
      case Muscle.brachialis:
        return 'Brachialis';
      case Muscle.forearms:
        return 'Forearms';
      case Muscle.quadriceps:
        return 'Quadriceps';
      case Muscle.hamstrings:
        return 'Hamstrings';
      case Muscle.glutes:
        return 'Glutes';
      case Muscle.calves:
        return 'Calves';
      case Muscle.tibialis:
        return 'Tibialis';
      case Muscle.adductors:
        return 'Adductors';
      case Muscle.abdominals:
        return 'Abdominals';
      case Muscle.upperAbs:
        return 'Upper Abs';
      case Muscle.lowerAbs:
        return 'Lower Abs';
      case Muscle.obliques:
        return 'Obliques';
      case Muscle.lowerBack:
        return 'Lower Back';
      case null:
        return 'Unknown';
    }
  }

  static String getDifficultyDisplayName(Difficulty? d) {
    switch (d) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.beginnerIntermediate:
        return 'Beginner / Intermediate';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.intermediateAdvanced:
        return 'Intermediate / Advanced';
      case Difficulty.advanced:
        return 'Advanced';
      case null:
        return 'Unknown';
    }
  }

  static String getSetTypeDisplayName(WorkoutSetType? s) {
    switch (s) {
      case WorkoutSetType.standard:
        return 'Standard';
      case WorkoutSetType.drop:
        return 'Drop';
      case WorkoutSetType.superSet:
        return 'Super';
      case WorkoutSetType.giant:
        return 'Giant';
      case WorkoutSetType.pyramid:
        return 'Pyramid';
      case WorkoutSetType.circuit:
        return 'Circuit';
      case null:
        return 'Unknown';
    }
  }

  static String getGenderDisplayName(Gender? g) {
    switch (g) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case null:
        return 'Unknown';
    }
  }

  static String getWorkoutPhaseDisplayName(WorkoutPhase? p) {
    switch (p) {
      case WorkoutPhase.endurance:
        return 'Endurance';
      case WorkoutPhase.hypertrophy:
        return 'Hypertrophy';
      case WorkoutPhase.maxStrength:
        return 'Max Strength';
      case WorkoutPhase.power:
        return 'Power';
      case null:
        return 'Unknown';
    }
  }

  static String getTimeOfDayDisplayName(WorkoutTimeOfDay? t) {
    switch (t) {
      case WorkoutTimeOfDay.morning:
        return 'Morning';
      case WorkoutTimeOfDay.afternoon:
        return 'Afternoon';
      case WorkoutTimeOfDay.evening:
        return 'Evening';
      case WorkoutTimeOfDay.night:
        return 'Night';
      case WorkoutTimeOfDay.anytime:
      case null:
        return 'Anytime';
    }
  }

  static String getWeightGoalPhaseDisplayName(WeightGoalPhase? g) {
    switch (g) {
      case WeightGoalPhase.cut:
        return 'Cut';
      case WeightGoalPhase.maintain:
        return 'Maintain';
      case WeightGoalPhase.bulk:
        return 'Bulk';
      case null:
        return 'Unknown';
    }
  }

  static String getProgressStatusDisplayName(ProgressStatus? s) {
    switch (s) {
      case ProgressStatus.inProgress:
        return 'In Progress';
      case ProgressStatus.abandoned:
        return 'Abandoned';
      case ProgressStatus.completed:
        return 'Completed';
      case null:
        return 'Unknown';
    }
  }
}
