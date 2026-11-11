// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../../../utils/errors.dart';
import '../../../utils/result.dart';
import '../../models/sqlite/profile_model.dart';
import '../../models/sqlite/reminders_config_model.dart';
import '../../models/sqlite/system_model.dart';
import '../../services/sqlite/dao.dart';
import '../../services/sqlite/database_helper.dart';
import '../../utils/dates.dart';
import '../../utils/enums.dart';
import '../core/repository.dart';
import './dtos/profile_dto.dart';
import './dtos/reminders_config_dto.dart';
import './dtos/system_dto.dart';
import 'inputs/profile_input.dart';
import 'inputs/reminders_config_input.dart';
import 'inputs/system_input.dart';

final class ProfileRepository implements Repository {
  final Dao<Profile> _profileDao;
  final Dao<System> _systemDao;
  final Dao<RemindersConfig> _remindersDao;

  final Logger _logger = Logger("Profile Repository");

  ProfileRepository({
    required this._profileDao,
    required this._systemDao,
    required this._remindersDao,
  });

  factory ProfileRepository.create([DatabaseHelper? databaseHelper]) {
    final helper = databaseHelper ?? DatabaseHelper();
    return ProfileRepository(
      profileDao: Dao<Profile>(
        databaseHelper: helper,
        tableName: Profile.table,
        fromMap: Profile.fromMap,
      ),
      systemDao: Dao<System>(
        databaseHelper: helper,
        tableName: System.table,
        fromMap: System.fromMap,
      ),
      remindersDao: Dao<RemindersConfig>(
        databaseHelper: helper,
        tableName: RemindersConfig.table,
        fromMap: RemindersConfig.fromMap,
      ),
    );
  }

  Profile _applyProfileInput(Profile existing, ProfileInput input) {
    return existing.copyWith(
      name: input.name,
      height: input.height,
      gender: input.gender,
      birthdate: DateUtilities.getNumericDate(input.birthday),
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
  }

  System _applySystemInput(System existing, SystemInput input) {
    return existing.copyWith(
      theme: input.theme,
      units: input.units,
      notificationsOn: input.notificationsOn,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
  }

  RemindersConfig _applyRemindersInput(
    RemindersConfig existing,
    RemindersConfigInput input,
  ) {
    return existing.copyWith(
      workoutsOn: input.workoutsOn,
      workoutsReminderTime: DateUtilities.getDateUnix(
        input.workoutsReminderTime,
      ),
      weightRecordsOn: input.weightRecordsOn,
      weightRecordsReminderTime: DateUtilities.getDateUnix(
        input.weightRecordsReminderTime,
      ),
      macroTrackingOn: input.macroTrackingOn,
      macroTrackingReminderTime: DateUtilities.getDateUnix(
        input.macroTrackingReminderTime,
      ),
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
  }

  Future<Result<ProfileDto, ServiceError<OperationErrorTypes>>> upsertProfile(
    ProfileInput input, [
    Transaction? transaction,
  ]) async {
    _logger.info("Upserting profile...");
    try {
      final Profile? existingProfile = await _profileDao.selectLatest(
        transaction,
      );

      if (existingProfile != null) {
        _logger.info('Profile already exists, updating...');
        final Profile updatedProfile = _applyProfileInput(
          existingProfile,
          input,
        );
        await _profileDao.update(updatedProfile, transaction);
        _logger.info('Updated profile with id ${updatedProfile.id}');
        return ok(ProfileDto.fromModel(updatedProfile));
      }

      final Profile profile = Profile.create(
        name: input.name,
        height: input.height,
        gender: input.gender,
        birthdate: input.birthday,
      );
      final int id = await _profileDao.insert(profile, transaction);
      _logger.info('Created profile with id $id');
      return ok(ProfileDto.fromModel(profile.copyWith(id: id)));
    } catch (e) {
      _logger.severe("Failed to upsert profile", e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to upsert profile',
        ),
      );
    }
  }

  Future<Result<ProfileDto, ServiceError<SingleErrorTypes>>> updateProfile(
    ProfileInput input,
  ) async {
    _logger.info("Updating profile...");
    try {
      final Profile? existingProfile = await _profileDao.selectLatest();

      if (existingProfile == null) {
        _logger.info("Profile does not exist");
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Profile not found',
          ),
        );
      }

      final Profile updatedProfile = _applyProfileInput(existingProfile, input);
      await _profileDao.update(updatedProfile);
      _logger.info('Updated profile with id ${updatedProfile.id}');
      return ok(ProfileDto.fromModel(updatedProfile));
    } catch (e) {
      _logger.severe("Failed to update profile", e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update profile',
        ),
      );
    }
  }

  Future<Result<ProfileDto, ServiceError<SingleErrorTypes>>> selectProfile([
    Transaction? transaction,
  ]) async {
    _logger.info("Getting latest profile...");
    try {
      final Profile? profile = await _profileDao.selectLatest(transaction);
      if (profile == null) {
        _logger.info("Profile does not exist");
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Profile not found',
          ),
        );
      }

      _logger.info("Profile found with id ${profile.id}");
      return ok(ProfileDto.fromModel(profile));
    } catch (e) {
      _logger.severe("Failed to get latest profile", e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get latest profile',
        ),
      );
    }
  }

  Future<Result<SystemDto, ServiceError<OperationErrorTypes>>> upsertSystem(
    SystemInput input,
    int profileId, [
    Transaction? transaction,
  ]) async {
    _logger.info('Upserting system...');
    try {
      final System? existingSystem = await _systemDao.selectLatest(transaction);

      if (existingSystem != null) {
        _logger.info('System already exists, updating...');
        final System updatedSystem = _applySystemInput(existingSystem, input);
        await _systemDao.update(updatedSystem, transaction);
        _logger.info('System updated successfully');
        return ok(SystemDto.fromModel(updatedSystem));
      }

      final System system = System.create(
        profileId: profileId,
        theme: input.theme,
        units: input.units,
        notificationsOn: input.notificationsOn,
      );
      final int id = await _systemDao.insert(system, transaction);
      _logger.info('System created successfully');
      return ok(SystemDto.fromModel(system.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to upsert system', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to upsert system',
        ),
      );
    }
  }

  Future<Result<SystemDto, ServiceError<SingleErrorTypes>>> updateSystem(
    SystemInput input,
  ) async {
    _logger.info('Updating system...');
    try {
      final System? existingSystem = await _systemDao.selectLatest();
      if (existingSystem == null) {
        _logger.info('System does not exist');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'System does not exist',
          ),
        );
      }

      final System updatedSystem = _applySystemInput(existingSystem, input);
      await _systemDao.update(updatedSystem);
      _logger.info('System updated successfully');
      return ok(SystemDto.fromModel(updatedSystem));
    } catch (e) {
      _logger.severe('Failed to update system', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update system',
        ),
      );
    }
  }

  Future<Result<SystemDto, ServiceError<SingleErrorTypes>>> selectSystem([
    Transaction? transaction,
  ]) async {
    _logger.info('Selecting latest system...');
    try {
      final System? system = await _systemDao.selectLatest(transaction);
      if (system == null) {
        _logger.info('No system found');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'No system found',
          ),
        );
      }

      _logger.info('System found');
      return ok(SystemDto.fromModel(system));
    } catch (e) {
      _logger.severe('Failed to select latest system', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to select latest system',
        ),
      );
    }
  }

  Future<Result<RemindersConfigDto, ServiceError<OperationErrorTypes>>>
  upsertRemindersConfig(
    RemindersConfigInput input,
    int profileId, [
    Transaction? transaction,
  ]) async {
    _logger.info('Upserting reminders config...');
    try {
      final RemindersConfig? existingConfig = await _remindersDao.selectLatest(
        transaction,
      );

      if (existingConfig != null) {
        _logger.info('Reminders config exists, updating...');
        final RemindersConfig updatedConfig = _applyRemindersInput(
          existingConfig,
          input,
        );
        await _remindersDao.update(updatedConfig, transaction);
        _logger.info('Updated reminders config with id ${updatedConfig.id}');
        return ok(RemindersConfigDto.fromModel(updatedConfig));
      }

      final RemindersConfig remindersConfig = RemindersConfig.create(
        workoutsOn: input.workoutsOn,
        workoutsReminderTime: input.workoutsReminderTime,
        weightRecordsOn: input.weightRecordsOn,
        weightRecordsReminderTime: input.weightRecordsReminderTime,
        macroTrackingOn: input.macroTrackingOn,
        macroTrackingReminderTime: input.macroTrackingReminderTime,
        profileId: profileId,
      );
      final int id = await _remindersDao.insert(remindersConfig, transaction);
      _logger.info('Created reminders config with id $id');
      return ok(RemindersConfigDto.fromModel(remindersConfig.copyWith(id: id)));
    } catch (e) {
      _logger.severe('Failed to upsert reminders config', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to upsert reminders config',
        ),
      );
    }
  }

  Future<Result<RemindersConfigDto, ServiceError<SingleErrorTypes>>>
  selectRemindersConfig([Transaction? transaction]) async {
    _logger.info('Selecting reminders config...');
    try {
      final RemindersConfig? remindersConfig = await _remindersDao.selectLatest(
        transaction,
      );
      if (remindersConfig == null) {
        _logger.info('Reminders config not found');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Reminders config not found',
          ),
        );
      }

      _logger.info('Reminders config found with id ${remindersConfig.id}');
      return ok(RemindersConfigDto.fromModel(remindersConfig));
    } catch (e) {
      _logger.severe('Failed to select reminders config', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to select reminders config',
        ),
      );
    }
  }

  Future<Result<RemindersConfigDto, ServiceError<SingleErrorTypes>>>
  updateRemindersConfig(RemindersConfigInput input) async {
    _logger.info('Updating reminders config...');
    try {
      final RemindersConfig? remindersConfig = await _remindersDao
          .selectLatest();
      if (remindersConfig == null) {
        _logger.info('Reminders config not found');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Reminders config not found',
          ),
        );
      }

      final RemindersConfig updatedConfig = _applyRemindersInput(
        remindersConfig,
        input,
      );
      await _remindersDao.update(updatedConfig);
      _logger.info('Updated reminders config with id ${updatedConfig.id}');
      return ok(RemindersConfigDto.fromModel(updatedConfig));
    } catch (e) {
      _logger.severe('Failed to update reminders config', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update reminders config',
        ),
      );
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
      final System? existingSystem = await _systemDao.selectLatest(transaction);
      if (existingSystem == null) {
        _logger.info('System does not exist');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'System does not exist',
          ),
        );
      }

      final System updatedSystem = existingSystem.copyWith(
        theme: theme,
        units: units,
        initialSetup: initialSetup,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _systemDao.update(updatedSystem, transaction);
      _logger.info('System upgraded successfully');
      return ok(SystemDto.fromModel(updatedSystem));
    } catch (e) {
      _logger.severe('Failed to upgrade system', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to upgrade system',
        ),
      );
    }
  }
}
