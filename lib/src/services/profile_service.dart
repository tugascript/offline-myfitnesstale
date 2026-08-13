import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../models/db.dart';
import '../models/enums.dart';
import '../models/profile_model.dart';
import '../models/reminders_config_model.dart';
import '../models/repository.dart';
import '../models/system_model.dart';
import '../models/utilities.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/profile_dto.dart';
import 'dtos/reminders_config_dto.dart';
import 'dtos/system_dto.dart';

class ProfileService {
  ProfileService._();

  static final ProfileService _instance = ProfileService._();

  factory ProfileService() => _instance;

  final Logger _logger = Logger("Profile Service");

  final _repository = Repository<Profile>(
    databaseHelper: DatabaseHelper(),
    tableName: Profile.table,
    fromMap: Profile.fromMap,
  );

  final _systemRepository = Repository<System>(
    databaseHelper: DatabaseHelper(),
    tableName: System.table,
    fromMap: System.fromMap,
  );

  final _remindersRepository = Repository<RemindersConfig>(
    databaseHelper: DatabaseHelper(),
    tableName: RemindersConfig.table,
    fromMap: RemindersConfig.fromMap,
  );

  Future<Result<ProfileDto, ServiceError<OperationErrorTypes>>> upsertProfile({
    required String name,
    required int height,
    required Gender gender,
    required DateTime birthday,
    Transaction? transaction,
  }) async {
    _logger.info("Upserting profile...");
    try {
      final Profile? existingProfile =
          await _repository.selectLatest(transaction);

      if (existingProfile != null) {
        _logger.info('Profile already exists, updating...');
        final Profile updatedProfile = existingProfile.copyWith(
          name: name,
          height: height,
          gender: gender,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _repository.update(updatedProfile, transaction);
        _logger.info('Updated profile with id ${updatedProfile.id}');
        return ok(ProfileDto.fromModel(updatedProfile));
      }

      final Profile profile = Profile.create(
        name,
        height,
        gender,
        birthday,
      );
      final int id = await _repository.insert(profile, transaction);
      _logger.info('Created profile with id $id');
      return ok(ProfileDto.fromModel(profile.copyWith(id: id)));
    } catch (e) {
      _logger.severe("Failed to upsert profile", e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to upsert profile',
      ));
    }
  }

  Future<Result<ProfileDto, ServiceError<SingleErrorTypes>>> updateProfile({
    String? name,
    int? height,
    Gender? gender,
  }) async {
    _logger.info("Updating profile...");
    try {
      final Profile? existingProfile = await _repository.selectLatest();

      if (existingProfile == null) {
        _logger.info("Profile does not exist");
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Profile not found',
        ));
      }

      final Profile updatedProfile = existingProfile.copyWith(
        name: name,
        height: height,
        gender: gender,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedProfile);
      _logger.info('Updated profile with id ${updatedProfile.id}');
      return ok(ProfileDto.fromModel(updatedProfile));
    } catch (e) {
      _logger.severe("Failed to update profile", e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update profile',
      ));
    }
  }

  Future<Result<ProfileDto, ServiceError<SingleErrorTypes>>> selectProfile({
    Transaction? transaction,
  }) async {
    _logger.info("Getting latest profile...");
    try {
      final Profile? profile = await _repository.selectLatest(transaction);
      if (profile == null) {
        _logger.info("Profile does not exist");
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Profile not found',
        ));
      }

      _logger.info("Profile found with id ${profile.id}");
      return ok(ProfileDto.fromModel(profile));
    } catch (e) {
      _logger.severe("Failed to get latest profile", e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get latest profile',
      ));
    }
  }

  Future<Result<SystemDto, ServiceError<OperationErrorTypes>>> upsertSystem({
    required ThemeType theme,
    required Units units,
    required int profileId,
    required bool notificationsOn,
    Transaction? transaction,
  }) async {
    _logger.info('Upserting system...');
    try {
      final System? existingSystem =
          await _systemRepository.selectLatest(transaction);

      if (existingSystem != null) {
        _logger.info('System already exists, updating...');
        final System updatedSystem = existingSystem.copyWith(
          theme: theme,
          units: units,
          notificationsOn: notificationsOn,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _systemRepository.update(updatedSystem, transaction);
        _logger.info('System updated successfully');
        return ok(SystemDto.fromModel(updatedSystem));
      }

      final System system = System.create(
        profileId: profileId,
        theme: theme,
        units: units,
        notificationsOn: notificationsOn,
      );
      final int id = await _systemRepository.insert(system, transaction);
      _logger.info('System created successfully');
      return ok(SystemDto.fromModel(system.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to upsert system', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to upsert system',
      ));
    }
  }

  Future<Result<SystemDto, ServiceError<SingleErrorTypes>>> selectSystem({
    Transaction? transaction,
  }) async {
    _logger.info('Selecting latest system...');
    try {
      final System? system = await _systemRepository.selectLatest(transaction);
      if (system == null) {
        _logger.info('No system found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'No system found',
        ));
      }

      _logger.info('System found');
      return ok(SystemDto.fromModel(system));
    } catch (e) {
      _logger.severe('Failed to select latest system', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to select latest system',
      ));
    }
  }

  Future<Result<RemindersConfigDto, ServiceError<OperationErrorTypes>>>
      upsertRemindersConfig({
    required int profileId,
    required bool workoutsOn,
    required bool weightRecordsOn,
    Transaction? transaction,
  }) async {
    _logger.info('Upserting reminders config...');
    try {
      final RemindersConfig? existingConfig =
          await _remindersRepository.selectLatest(transaction);

      if (existingConfig != null) {
        _logger.info('Reminders config exists, updating...');
        final RemindersConfig updatedConfig = existingConfig.copyWith(
          workoutsOn: workoutsOn,
          weightRecordsOn: weightRecordsOn,
          updatedAt: DateUtilities.getNowUtcUnix(),
        );
        await _remindersRepository.update(updatedConfig, transaction);
        _logger.info('Updated reminders config with id ${updatedConfig.id}');
        return ok(RemindersConfigDto.fromModel(updatedConfig));
      }

      final RemindersConfig remindersConfig = RemindersConfig.create(
        workoutsOn: workoutsOn,
        weightRecordsOn: weightRecordsOn,
        profileId: profileId,
      );
      final int id =
          await _remindersRepository.insert(remindersConfig, transaction);
      _logger.info('Created reminders config with id $id');
      return ok(
        RemindersConfigDto.fromModel(remindersConfig.copyWith(id: id)),
      );
    } catch (e) {
      _logger.severe('Failed to upsert reminders config', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to upsert reminders config',
      ));
    }
  }

  Future<Result<RemindersConfigDto, ServiceError<SingleErrorTypes>>>
      selectRemindersConfig({Transaction? transaction}) async {
    _logger.info('Selecting reminders config...');
    try {
      final RemindersConfig? remindersConfig =
          await _remindersRepository.selectLatest(transaction);
      if (remindersConfig == null) {
        _logger.info('Reminders config not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Reminders config not found',
        ));
      }

      _logger.info('Reminders config found with id ${remindersConfig.id}');
      return ok(RemindersConfigDto.fromModel(remindersConfig));
    } catch (e) {
      _logger.severe('Failed to select reminders config', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to select reminders config',
      ));
    }
  }

  Future<Result<RemindersConfigDto, ServiceError<SingleErrorTypes>>>
      updateRemindersConfig({
    bool? workoutsOn,
    bool? weightRecordsOn,
  }) async {
    _logger.info('Updating reminders config...');
    try {
      final RemindersConfig? remindersConfig =
          await _remindersRepository.selectLatest();
      if (remindersConfig == null) {
        _logger.info('Reminders config not found');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Reminders config not found',
        ));
      }

      final RemindersConfig updatedConfig = remindersConfig.copyWith(
        workoutsOn: workoutsOn,
        weightRecordsOn: weightRecordsOn,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _remindersRepository.update(updatedConfig);
      _logger.info('Updated reminders config with id ${updatedConfig.id}');
      return ok(RemindersConfigDto.fromModel(updatedConfig));
    } catch (e) {
      _logger.severe('Failed to update reminders config', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to update reminders config',
      ));
    }
  }

  Future<Result<SystemDto, ServiceError<SingleErrorTypes>>> upgradeSystem({
    ThemeType? theme,
    Units? units,
    SetUpStatus? exerciseSetup,
    SetUpStatus? workoutSetup,
    SetUpStatus? workoutPlanSetup,
    SetUpStatus? initialSetup,
    Transaction? transaction,
  }) async {
    _logger.info('Upgrading system...');
    try {
      final System? existingSystem =
          await _systemRepository.selectLatest(transaction);
      if (existingSystem == null) {
        _logger.info('System does not exist');
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'System does not exist',
        ));
      }

      final System updatedSystem = existingSystem.copyWith(
        theme: theme,
        units: units,
        initialSetup: initialSetup,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _systemRepository.update(updatedSystem, transaction);
      _logger.info('System upgraded successfully');
      return ok(SystemDto.fromModel(updatedSystem));
    } catch (e) {
      _logger.severe('Failed to upgrade system', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to upgrade system',
      ));
    }
  }
}
