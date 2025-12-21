enum Gender {
  male("male"),
  female("female"),
  other("other");

  final String value;

  const Gender(this.value);

  static Gender fromValue(String v) => Gender.values.firstWhere(
        (g) => g.value == v,
        orElse: () => Gender.other,
      );
}

enum Units {
  metric("metric"),
  imperial("imperial");

  final String value;

  const Units(this.value);

  static Units fromValue(String v) => Units.values.firstWhere(
        (u) => u.value == v,
        orElse: () => Units.metric,
      );
}

enum ThemeType {
  system("system"),
  light("light"),
  dark("dark");

  final String value;

  const ThemeType(this.value);

  static ThemeType fromValue(String v) => ThemeType.values.firstWhere(
        (t) => t.value == v,
        orElse: () => ThemeType.system,
      );
}

enum ExerciseMuscleCategory {
  primary("primary"),
  secondary("secondary");

  final String value;

  const ExerciseMuscleCategory(this.value);

  static ExerciseMuscleCategory fromValue(String v) =>
      ExerciseMuscleCategory.values.firstWhere(
        (e) => e.value == v,
        orElse: () => ExerciseMuscleCategory.primary,
      );
}

enum VideoPlatform {
  youtube('youtube'),
  vimeo('vimeo'),
  facebook('facebook'),
  tiktok('tiktok'),
  instagram('instagram'),
  dailymotion('dailymotion'),
  custom('custom');

  final String value;

  const VideoPlatform(this.value);

  static VideoPlatform fromValue(String v) => VideoPlatform.values.firstWhere(
        (p) => p.value == v,
        orElse: () => VideoPlatform.youtube,
      );
}

enum Difficulty {
  beginner(1),
  beginnerIntermediate(2),
  intermediate(3),
  intermediateAdvanced(4),
  advanced(5);

  final int value;

  const Difficulty(this.value);

  static Difficulty fromValue(int v) => Difficulty.values.firstWhere(
        (d) => d.value == v,
        orElse: () => Difficulty.beginner,
      );
}

enum TimeOfDay {
  anytime("anytime"),
  morning("morning"),
  afternoon("afternoon"),
  evening("evening"),
  night("night");

  final String value;

  const TimeOfDay(this.value);

  static TimeOfDay fromValue(String v) => TimeOfDay.values.firstWhere(
        (t) => t.value == v,
        orElse: () => TimeOfDay.anytime,
      );
}

enum SetUpStatus {
  notStarted("not_started"),
  skipped("skipped"),
  completed("completed");

  final String value;

  const SetUpStatus(this.value);

  static SetUpStatus fromValue(String v) => SetUpStatus.values.firstWhere(
        (s) => s.value == v,
        orElse: () => SetUpStatus.notStarted,
      );
}

enum ProgressStatus {
  inProgress("in_progress"),
  completed("completed"),
  abandoned("abandoned");

  final String value;

  const ProgressStatus(this.value);

  static ProgressStatus fromValue(String v) => ProgressStatus.values.firstWhere(
        (p) => p.value == v,
        orElse: () => ProgressStatus.inProgress,
      );
}

enum WorkoutSetExerciseDifficulty {
  rir("RIR"),
  rpe("RPE"),
  rmp("RMP");

  final String value;

  const WorkoutSetExerciseDifficulty(this.value);

  static WorkoutSetExerciseDifficulty fromValue(String v) =>
      WorkoutSetExerciseDifficulty.values.firstWhere(
        (d) => d.value == v,
        orElse: () => WorkoutSetExerciseDifficulty.rir,
      );
}
