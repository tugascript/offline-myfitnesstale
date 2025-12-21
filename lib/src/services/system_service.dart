import '../models/db.dart';
import '../models/enums.dart';
import '../models/repository.dart';
import '../models/system_model.dart';
import '../models/utilities.dart';

class SystemService {
  SystemService._();

  static final SystemService _instance = SystemService._();

  factory SystemService() => _instance;

  final Repository<System> _repository = Repository<System>(
    databaseHelper: DatabaseHelper(),
    tableName: System.table,
    fromMap: (map) => System.fromMap(map),
  );

  Future<System?> selectLatest() async {
    return await _repository.selectLatest();
  }

  Future<System> upsertSystem({
    required int profileId,
    required ThemeType theme,
    required Units units,
  }) async {
    final System? existingSystem = await _repository.selectLatest();

    if (existingSystem != null) {
      final System updatedSystem = existingSystem.copyWith(
        profileId: profileId,
        theme: theme,
        units: units,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedSystem);
      return updatedSystem;
    }

    final System system = System.create(
      profileId,
      theme,
      units,
    );
    final int id = await _repository.insert(system);
    return system.copyWith(id: id);
  }

  Future<System> upgradeSystem({
    ThemeType? theme,
    Units? units,
    SetUpStatus? muscleGroupSetup,
    SetUpStatus? muscleSetup,
    SetUpStatus? exerciseSetup,
    SetUpStatus? workoutSetup,
    SetUpStatus? workoutPlanSetup,
    SetUpStatus? initialSetup,
  }) async {
    final System? existingSystem = await _repository.selectLatest();

    if (existingSystem == null) {
      throw Exception('System does not exist');
    }

    final System updatedSystem = existingSystem.copyWith(
      theme: theme,
      units: units,
      muscleGroupSetup: muscleGroupSetup,
      muscleSetup: muscleSetup,
      exerciseSetup: exerciseSetup,
      workoutSetup: workoutSetup,
      workoutPlanSetup: workoutPlanSetup,
      initialSetup: initialSetup,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedSystem);
    return updatedSystem;
  }
}
