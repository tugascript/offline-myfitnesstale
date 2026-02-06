enum CreatedBy {
  user("user"),
  system("system");

  final String value;

  const CreatedBy(this.value);

  static CreatedBy fromValue(String v) => CreatedBy.values.firstWhere(
        (c) => c.value == v,
        orElse: () => CreatedBy.user,
      );
}

enum MuscleGroup {
  full("full"),
  push("push"),
  pull("pull"),
  legs("legs"),
  core("core");

  final String value;

  const MuscleGroup(this.value);

  static MuscleGroup fromValue(String v) => MuscleGroup.values.firstWhere(
        (m) => m.value == v,
        orElse: () => MuscleGroup.full,
      );
}

enum Muscle {
  chest("chest"),
  upperChest("upper_chest"),
  lowerChest("lower_chest"),
  innerChest("inner_chest"),
  shoulders("shoulders"),
  frontDelts("front_delts"),
  sideDelts("side_delts"),
  rearDelts("rear_delts"),
  triceps("triceps"),
  neck("neck"),
  trapezius("trapezius"),
  upperTrapezius("upper_trapezius"),
  middleTrapezius("middle_trapezius"),
  lowerTrapezius("lower_trapezius"),
  rhomboids("rhomboids"),
  lats("lats"),
  biceps("biceps"),
  brachialis("brachialis"),
  forearms("forearms"),
  quadriceps("quadriceps"),
  hamstrings("hamstrings"),
  glutes("glutes"),
  calves("calves"),
  tibialis("tibialis"),
  adductors("adductors"),
  abdominals("abdominals"),
  upperAbs("upper_abs"),
  lowerAbs("lower_abs"),
  obliques("obliques"),
  lowerBack("lower_back");

  final String value;

  const Muscle(this.value);

  static Muscle fromValue(String v) => Muscle.values.firstWhere(
        (m) => m.value == v,
        orElse: () => Muscle.chest,
      );
}

const Map<MuscleGroup, Set<Muscle>> kMuscleGroupMuscleMap = {
  MuscleGroup.full: {
    Muscle.chest,
    Muscle.upperChest,
    Muscle.lowerChest,
    Muscle.innerChest,
    Muscle.shoulders,
    Muscle.frontDelts,
    Muscle.sideDelts,
    Muscle.rearDelts,
    Muscle.triceps,
    Muscle.neck,
    Muscle.trapezius,
    Muscle.upperTrapezius,
    Muscle.middleTrapezius,
    Muscle.lowerTrapezius,
    Muscle.rhomboids,
    Muscle.lats,
    Muscle.biceps,
    Muscle.brachialis,
    Muscle.forearms,
    Muscle.quadriceps,
    Muscle.hamstrings,
    Muscle.glutes,
    Muscle.calves,
    Muscle.tibialis,
    Muscle.adductors,
    Muscle.abdominals,
    Muscle.upperAbs,
    Muscle.lowerAbs,
    Muscle.obliques,
    Muscle.lowerBack,
  },
  MuscleGroup.push: {
    Muscle.chest,
    Muscle.upperChest,
    Muscle.lowerChest,
    Muscle.upperTrapezius,
    Muscle.innerChest,
    Muscle.shoulders,
    Muscle.frontDelts,
    Muscle.sideDelts,
    Muscle.triceps,
  },
  MuscleGroup.pull: {
    Muscle.rearDelts,
    Muscle.neck,
    Muscle.trapezius,
    Muscle.upperTrapezius,
    Muscle.middleTrapezius,
    Muscle.lowerTrapezius,
    Muscle.rhomboids,
    Muscle.lats,
    Muscle.biceps,
    Muscle.brachialis,
    Muscle.forearms,
  },
  MuscleGroup.legs: {
    Muscle.quadriceps,
    Muscle.hamstrings,
    Muscle.glutes,
    Muscle.calves,
    Muscle.tibialis,
    Muscle.adductors,
  },
  MuscleGroup.core: {
    Muscle.abdominals,
    Muscle.upperAbs,
    Muscle.lowerAbs,
    Muscle.obliques,
    Muscle.lowerBack,
  },
};

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

enum VideoPlatform {
  youtube('youtube'),
  vimeo('vimeo'),
  facebook('facebook'),
  tiktok('tiktok'),
  instagram('instagram'),
  dailymotion('dailymotion'),
  assets('assets'),
  files('files'),
  custom('custom');

  final String value;

  const VideoPlatform(this.value);

  static VideoPlatform fromValue(String v) => VideoPlatform.values.firstWhere(
        (p) => p.value == v,
        orElse: () => VideoPlatform.youtube,
      );
}

enum PictureStorage {
  assets("assets"),
  files("files"),
  network("network");

  final String value;

  const PictureStorage(this.value);

  static PictureStorage fromValue(String v) => PictureStorage.values.firstWhere(
        (p) => p.value == v,
        orElse: () => PictureStorage.files,
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

enum WorkoutTimeOfDay {
  anytime("anytime"),
  morning("morning"),
  afternoon("afternoon"),
  evening("evening"),
  night("night");

  final String value;

  const WorkoutTimeOfDay(this.value);

  static WorkoutTimeOfDay fromValue(String v) =>
      WorkoutTimeOfDay.values.firstWhere(
        (t) => t.value == v,
        orElse: () => WorkoutTimeOfDay.anytime,
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

enum WorkoutPhase {
  endurance("endurance"),
  hypertrophy("hypertrophy"),
  maxStrength("max_strength"),
  power("power");

  final String value;

  const WorkoutPhase(this.value);

  static WorkoutPhase fromValue(String v) => WorkoutPhase.values.firstWhere(
        (p) => p.value == v,
        orElse: () => WorkoutPhase.endurance,
      );
}

enum WorkoutSetExerciseDifficultyType {
  rir("RIR"),
  rpe("RPE"),
  rmp("RMP");

  final String value;

  const WorkoutSetExerciseDifficultyType(this.value);

  static WorkoutSetExerciseDifficultyType fromValue(String v) =>
      WorkoutSetExerciseDifficultyType.values.firstWhere(
        (d) => d.value == v,
        orElse: () => WorkoutSetExerciseDifficultyType.rir,
      );
}

enum WorkoutSetType {
  standard("standard"),
  drop("drop"),
  superSet("super"),
  giant("giant"),
  pyramid("pyramid"),
  circuit("circuit");

  final String value;

  const WorkoutSetType(this.value);

  static WorkoutSetType fromValue(String v) => WorkoutSetType.values.firstWhere(
        (t) => t.value == v,
        orElse: () => WorkoutSetType.standard,
      );
}

enum ReminderSchedule {
  daily("daily"),
  weekly("weekly"),
  monthly("monthly");

  final String value;

  const ReminderSchedule(this.value);

  static ReminderSchedule fromValue(String v) =>
      ReminderSchedule.values.firstWhere(
        (s) => s.value == v,
        orElse: () => ReminderSchedule.daily,
      );
}

enum DayOfWeek {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  final int value;

  const DayOfWeek(this.value);
}
