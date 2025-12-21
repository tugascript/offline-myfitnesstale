import '../models/current_workout_plan_record_model.dart';
import '../models/db.dart';
import '../models/profile_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import '../services/profile_service.dart';

class CurrentWorkoutPlanRecordService {
  CurrentWorkoutPlanRecordService._();

  static final CurrentWorkoutPlanRecordService instance =
      CurrentWorkoutPlanRecordService._();

  factory CurrentWorkoutPlanRecordService() => instance;

  final Repository<CurrentWorkoutPlanRecord> _repository =
      Repository<CurrentWorkoutPlanRecord>(
    databaseHelper: DatabaseHelper(),
    tableName: CurrentWorkoutPlanRecord.table,
    fromMap: (map) => CurrentWorkoutPlanRecord.fromMap(map),
  );

  final ProfileService _profileService = ProfileService();

  Future<CurrentWorkoutPlanRecord?> getCurrentWorkoutPlanRecord([
    Profile? profile,
  ]) async {
    // If profile is not provided, fetch it
    Profile? profileToUse = profile;
    profileToUse ??= await _profileService.selectLatest();

    if (profileToUse == null || profileToUse.id == null) {
      return null;
    }

    final List<CurrentWorkoutPlanRecord> records = await _repository.selectMany(
      where: 'profile_id = ?',
      whereArgs: [profileToUse.id!],
      orderBy: 'created_at DESC',
    );

    if (records.isEmpty) {
      return null;
    }

    return records.first;
  }

  Future<CurrentWorkoutPlanRecord?> setCurrentWorkoutPlan(
    int workoutPlanId,
  ) async {
    final profile = await _profileService.selectLatest();
    if (profile == null || profile.id == null) {
      throw Exception('Profile does not exist');
    }

    // Check if there's already a current plan
    final CurrentWorkoutPlanRecord? existing =
        await getCurrentWorkoutPlanRecord();

    if (existing != null) {
      // Update existing record
      final CurrentWorkoutPlanRecord updated = existing.copyWith(
        workoutPlanId: workoutPlanId,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updated);
      return updated;
    } else {
      // Create new record
      final CurrentWorkoutPlanRecord record = CurrentWorkoutPlanRecord.create(
        workoutPlanId,
        profile.id!,
      );
      final int id = await _repository.insert(record);
      return record.copyWith(id: id);
    }
  }

  Future<bool> clearCurrentWorkoutPlan() async {
    final CurrentWorkoutPlanRecord? current =
        await getCurrentWorkoutPlanRecord();
    if (current == null || current.id == null) {
      return false;
    }

    return await _repository.deleteOne(current.id!);
  }

  Future<bool> hasActivePlan() async {
    final CurrentWorkoutPlanRecord? current =
        await getCurrentWorkoutPlanRecord();
    return current != null;
  }
}
