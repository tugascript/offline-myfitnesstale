import '../models/meal_plan_week_model.dart';
import '../models/meal_plan_day_model.dart';
import '../models/meal_log_model.dart';

import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/daily_nutrition_log_model.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/meal_plan_day_record_model.dart';
import '../models/meal_plan_model.dart';
import '../models/meal_plan_record_model.dart';
import '../models/meal_plan_week_record_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/meal_plan_record_dto.dart';
import 'dtos/paginated_dto.dart';

class MealPlanRecordService {
  MealPlanRecordService._();

  static final MealPlanRecordService _instance = MealPlanRecordService._();

  factory MealPlanRecordService() => _instance;

  final Repository<MealLog> _mealLogRepository = Repository<MealLog>(
    databaseHelper: DatabaseHelper(),
    tableName: MealLog.table,
    fromMap: MealLog.fromMap,
  );

  final Repository<MealPlanDay> _mealPlanDayRepository =
      Repository<MealPlanDay>(
        databaseHelper: DatabaseHelper(),
        tableName: MealPlanDay.table,
        fromMap: MealPlanDay.fromMap,
      );

  final Repository<MealPlanWeek> _mealPlanWeekRepository =
      Repository<MealPlanWeek>(
        databaseHelper: DatabaseHelper(),
        tableName: MealPlanWeek.table,
        fromMap: MealPlanWeek.fromMap,
      );

  final Logger _logger = Logger('Meal Plan Record Service');

  final Repository<MealPlanRecord> _recordRepository =
      Repository<MealPlanRecord>(
        databaseHelper: DatabaseHelper(),
        tableName: MealPlanRecord.table,
        fromMap: MealPlanRecord.fromMap,
      );

  final Repository<MealPlanWeekRecord> _weekRecordRepository =
      Repository<MealPlanWeekRecord>(
        databaseHelper: DatabaseHelper(),
        tableName: MealPlanWeekRecord.table,
        fromMap: MealPlanWeekRecord.fromMap,
      );

  final Repository<MealPlanDayRecord> _dayRecordRepository =
      Repository<MealPlanDayRecord>(
        databaseHelper: DatabaseHelper(),
        tableName: MealPlanDayRecord.table,
        fromMap: MealPlanDayRecord.fromMap,
      );

  final Repository<MealPlan> _mealPlanRepository = Repository<MealPlan>(
    databaseHelper: DatabaseHelper(),
    tableName: MealPlan.table,
    fromMap: MealPlan.fromMap,
  );

  final Repository<DailyNutritionLog> _dailyLogRepository =
      Repository<DailyNutritionLog>(
        databaseHelper: DatabaseHelper(),
        tableName: DailyNutritionLog.table,
        fromMap: DailyNutritionLog.fromMap,
      );

  Future<Result<MealPlanRecordDto, ServiceError<SingleErrorTypes>>>
  startMealPlan({
    required int mealPlanId,
    int? version,
    DateTime? startDate,
  }) async {
    _logger.info('Starting meal plan $mealPlanId');
    try {
      final MealPlan? plan = await _mealPlanRepository.selectOne(mealPlanId);
      if (plan == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Meal plan not found',
          ),
        );
      }

      final int targetVersion = version ?? plan.version;
      final startDt = startDate ?? DateTime.now();
      final baseDate = DateTime(startDt.year, startDt.month, startDt.day);
      final int startUnix = DateUtilities.getDateUnix(baseDate);

      return await _recordRepository.startTransaction<
        Result<MealPlanRecordDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        // 1. Abandon existing in-progress meal plan record
        {
          final models = await _recordRepository.selectMany(
            where: '${MealPlanRecordColumns.status.value} = ?',
            whereArgs: [ProgressStatus.inProgress.value],
            trx: txn,
          );
          for (final model in models) {
            await _recordRepository.update(
              model.copyWith(
                status: ProgressStatus.abandoned,
                completedAt: Nullable(DateUtilities.getNowUtcUnix()),
                updatedAt: DateUtilities.getNowUtcUnix(),
              ),
              txn,
            );
          }
        }

        // 2. Load plan's weeks and days for targetVersion
        final weekRows = await _mealPlanWeekRepository.selectMany(
          where:
              '${MealPlanWeekColumns.mealPlanId.value} = ? AND ${MealPlanWeekColumns.planVersion.value} = ?',
          whereArgs: [mealPlanId, targetVersion],
          orderBy: ['${MealPlanWeekColumns.weekNumber.value} ASC'],
          trx: txn,
        );

        if (weekRows.isEmpty) {
          throw const ServiceError(
            type: SingleErrorTypes.invalidInput,
            description: 'Meal plan has no configured weeks',
          );
        }

        // 3. Create active MealPlanRecord
        final record = MealPlanRecord.create(
          mealPlanId: mealPlanId,
          mealPlanVersion: targetVersion,
          status: ProgressStatus.inProgress,
          startedAt: startUnix,
          currentWeek: 1,
          currentDay: 1,
        );
        final int recordId = await _recordRepository.insert(record, txn);

        final List<MealPlanWeekRecordDto> weekRecordDtos = [];

        for (final wRow in weekRows) {
          final w = wRow;

          final weekRecord = MealPlanWeekRecord.create(
            mealPlanRecordId: recordId,
            mealPlanWeekId: w.id!,
            week: w.weekNumber,
            status: ProgressStatus.inProgress,
            currentDay: 1,
          );
          final int weekRecordId = await _weekRecordRepository.insert(
            weekRecord,
            txn,
          );

          final dayRows = await _mealPlanDayRepository.selectMany(
            where: '${MealPlanDayColumns.mealPlanWeekId.value} = ?',
            whereArgs: [w.id!],
            orderBy: ['${MealPlanDayColumns.day.value} ASC'],
            trx: txn,
          );

          final List<MealPlanDayRecordDto> dayRecordDtos = [];

          for (final dRow in dayRows) {
            final d = dRow;

            // Compute calendar date for this week and day
            final int offsetDays = (w.weekNumber - 1) * 7 + (d.day - 1);
            final DateTime dayCalendarDate = baseDate.add(
              Duration(days: offsetDays),
            );
            final int numericDate = DateUtilities.getNumericDate(
              dayCalendarDate,
            );

            // Get or create DailyNutritionLog for that calendar day
            final existingLogRows = await _dailyLogRepository.selectMany(
              where: '${DailyNutritionLogColumns.date.value} = ?',
              whereArgs: [numericDate],
              limit: 1,
              trx: txn,
            );

            int dailyLogId;
            if (existingLogRows.isNotEmpty) {
              dailyLogId = existingLogRows.first.id!;
            } else {
              final newDailyLog = DailyNutritionLog.create(date: numericDate);
              dailyLogId = await _dailyLogRepository.insert(newDailyLog, txn);
            }

            final dayRecord = MealPlanDayRecord.create(
              mealPlanRecordId: recordId,
              mealPlanWeekRecordId: weekRecordId,
              mealPlanDayId: d.id!,
              dailyLogId: dailyLogId,
              week: w.weekNumber,
              day: d.day,
              status: ProgressStatus.inProgress,
            );
            final int dayRecordId = await _dayRecordRepository.insert(
              dayRecord,
              txn,
            );

            dayRecordDtos.add(
              MealPlanDayRecordDto.fromModel(
                dayRecord.copyWith(id: Nullable(dayRecordId)),
              ),
            );
          }

          weekRecordDtos.add(
            MealPlanWeekRecordDto.fromModel(
              weekRecord.copyWith(id: Nullable(weekRecordId)),
              days: dayRecordDtos,
            ),
          );
        }

        final createdDto = MealPlanRecordDto.fromModel(
          record.copyWith(id: Nullable(recordId)),
          planName: plan.name,
          totalWeeks: plan.totalWeeks,
          totalDays: plan.totalDays,
          weeks: weekRecordDtos,
        );
        _logger.info('Started meal plan with record id $recordId');
        return ok(createdDto);
      });
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to start meal plan $mealPlanId', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to start meal plan',
        ),
      );
    }
  }

  Future<Result<MealPlanRecordDto, ServiceError<SingleErrorTypes>>>
  getActiveMealPlanRecord() async {
    _logger.info('Getting active meal plan record');
    try {
      final records = await _recordRepository.selectMany(
        where: MealPlanRecordColumns.status.equal,
        whereArgs: [ProgressStatus.inProgress.value],
        orderBy: [MealPlanRecordColumns.startedAt.orderDesc],
        limit: 1,
      );
      if (records.isEmpty) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'No active meal plan record',
          ),
        );
      }

      final active = records.first;
      final plan = await _mealPlanRepository.selectOne(active.mealPlanId);

      // Load weeks and days
      final weekRecords = await _weekRecordRepository.selectMany(
        where: '${MealPlanWeekRecordColumns.mealPlanRecordId.value} = ?',
        whereArgs: [active.id!],
        orderBy: [MealPlanWeekRecordColumns.week.orderAsc],
      );

      final List<MealPlanWeekRecordDto> weekDtos = [];
      for (final wRec in weekRecords) {
        final dayRecords = await _dayRecordRepository.selectMany(
          where: '${MealPlanDayRecordColumns.mealPlanWeekRecordId.value} = ?',
          whereArgs: [wRec.id!],
          orderBy: [MealPlanDayRecordColumns.day.orderAsc],
        );
        weekDtos.add(
          MealPlanWeekRecordDto.fromModel(
            wRec,
            days: dayRecords
                .map((d) => MealPlanDayRecordDto.fromModel(d))
                .toList(),
          ),
        );
      }

      return ok(
        MealPlanRecordDto.fromModel(
          active,
          planName: plan?.name,
          totalWeeks: plan?.totalWeeks ?? 1,
          totalDays: plan?.totalDays ?? 7,
          weeks: weekDtos,
        ),
      );
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to get active meal plan record', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get active meal plan record',
        ),
      );
    }
  }

  Future<Result<MealPlanRecordDto, ServiceError<SingleErrorTypes>>>
  completeCurrentDay({required int recordId}) async {
    _logger.info('Completing current day for meal plan record $recordId');
    try {
      return await _recordRepository.startTransaction<
        Result<MealPlanRecordDto, ServiceError<SingleErrorTypes>>
      >((txn) async {
        final recordRows = await _recordRepository.selectMany(
          where: '${MealPlanRecordColumns.id.value} = ?',
          whereArgs: [recordId],
          limit: 1,
          trx: txn,
        );
        if (recordRows.isEmpty) {
          throw const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Meal plan record not found',
          );
        }
        final record = recordRows.first;
        if (record.status != ProgressStatus.inProgress) {
          throw const ServiceError(
            type: SingleErrorTypes.invalidInput,
            description: 'Record is not currently in progress',
          );
        }

        // Find current week record
        final weekRecRows = await _weekRecordRepository.selectMany(
          where:
              '${MealPlanWeekRecordColumns.mealPlanRecordId.value} = ? AND ${MealPlanWeekRecordColumns.week.value} = ?',
          whereArgs: [recordId, record.currentWeek],
          limit: 1,
          trx: txn,
        );
        if (weekRecRows.isEmpty) {
          throw const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Current week record not found',
          );
        }
        final currentWeekRec = weekRecRows.first;

        // Find current day record
        final dayRecRows = await _dayRecordRepository.selectMany(
          where:
              '${MealPlanDayRecordColumns.mealPlanWeekRecordId.value} = ? AND ${MealPlanDayRecordColumns.day.value} = ?',
          whereArgs: [currentWeekRec.id!, record.currentDay],
          limit: 1,
          trx: txn,
        );
        if (dayRecRows.isEmpty) {
          throw const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Current day record not found',
          );
        }
        final currentDayRec = dayRecRows.first;

        // Roll up logged totals from DailyNutritionLog
        final mealLogRows = await _mealLogRepository.selectMany(
          where: '${MealLogColumns.dailyLogId.value} = ?',
          whereArgs: [currentDayRec.dailyLogId],
          trx: txn,
        );

        int dayCals = 0;
        int dayProtein = 0;
        int dayCarbs = 0;
        int dayFat = 0;
        int dayFiber = 0;

        for (final mRow in mealLogRows) {
          final m = mRow;
          dayCals += m.totalCalories;
          dayProtein += m.totalProtein;
          dayCarbs += m.totalCarbs;
          dayFat += m.totalFat;
          dayFiber += m.totalFiber ?? 0;
        }

        final now = DateUtilities.getNowUtcUnix();

        // Mark current day completed
        final updatedDay = currentDayRec.copyWith(
          status: ProgressStatus.completed,
          completedAt: Nullable(now),
          totalCalories: dayCals,
          totalProtein: dayProtein,
          totalCarbs: dayCarbs,
          totalFat: dayFat,
          totalFiber: Nullable(dayFiber),
          updatedAt: now,
        );
        await _dayRecordRepository.update(updatedDay, txn);

        // Check if there is another day in this week
        final allDaysInWeekRows = await _dayRecordRepository.selectMany(
          where: '${MealPlanDayRecordColumns.mealPlanWeekRecordId.value} = ?',
          whereArgs: [currentWeekRec.id!],
          orderBy: ['${MealPlanDayRecordColumns.day.value} ASC'],
          trx: txn,
        );
        final allDaysInWeek = allDaysInWeekRows.map((r) => r).toList();

        final nextDay = allDaysInWeek
            .where((d) => d.day > record.currentDay)
            .firstOrNull;

        if (nextDay != null) {
          // Advance day in same week
          {
            final models = await _dayRecordRepository.selectMany(
              where: '${MealPlanDayRecordColumns.id.value} = ?',
              whereArgs: [nextDay.id!],
              trx: txn,
            );
            for (final model in models) {
              await _dayRecordRepository.update(
                model.copyWith(
                  status: ProgressStatus.inProgress,
                  updatedAt: now,
                ),
                txn,
              );
            }
          }

          {
            final models = await _weekRecordRepository.selectMany(
              where: '${MealPlanWeekRecordColumns.id.value} = ?',
              whereArgs: [currentWeekRec.id!],
              trx: txn,
            );
            for (final model in models) {
              await _weekRecordRepository.update(
                model.copyWith(currentDay: nextDay.day, updatedAt: now),
                txn,
              );
            }
          }

          {
            final models = await _recordRepository.selectMany(
              where: '${MealPlanRecordColumns.id.value} = ?',
              whereArgs: [recordId],
              trx: txn,
            );
            for (final model in models) {
              await _recordRepository.update(
                model.copyWith(currentDay: nextDay.day, updatedAt: now),
                txn,
              );
            }
          }
        } else {
          // Complete current week
          int weekCals = 0;
          int weekProtein = 0;
          int weekCarbs = 0;
          int weekFat = 0;
          int weekFiber = 0;

          for (final d in allDaysInWeek) {
            if (d.id == updatedDay.id) {
              weekCals += dayCals;
              weekProtein += dayProtein;
              weekCarbs += dayCarbs;
              weekFat += dayFat;
              weekFiber += dayFiber;
            } else {
              weekCals += d.totalCalories;
              weekProtein += d.totalProtein;
              weekCarbs += d.totalCarbs;
              weekFat += d.totalFat;
              weekFiber += d.totalFiber ?? 0;
            }
          }

          {
            final models = await _weekRecordRepository.selectMany(
              where: '${MealPlanWeekRecordColumns.id.value} = ?',
              whereArgs: [currentWeekRec.id!],
              trx: txn,
            );
            for (final model in models) {
              await _weekRecordRepository.update(
                model.copyWith(
                  status: ProgressStatus.completed,
                  completedAt: Nullable(now),
                  totalCalories: weekCals,
                  totalProtein: weekProtein,
                  totalCarbs: weekCarbs,
                  totalFat: weekFat,
                  totalFiber: Nullable(weekFiber),
                  updatedAt: now,
                ),
                txn,
              );
            }
          }

          // Check if there is a next week
          final allWeeksRows = await _weekRecordRepository.selectMany(
            where: '${MealPlanWeekRecordColumns.mealPlanRecordId.value} = ?',
            whereArgs: [recordId],
            orderBy: ['${MealPlanWeekRecordColumns.week.value} ASC'],
            trx: txn,
          );
          final allWeeks = allWeeksRows.map((r) => r).toList();

          final nextWeek = allWeeks
              .where((w) => w.week > record.currentWeek)
              .firstOrNull;

          if (nextWeek != null) {
            // Advance to next week
            {
              final models = await _weekRecordRepository.selectMany(
                where: '${MealPlanWeekRecordColumns.id.value} = ?',
                whereArgs: [nextWeek.id!],
                trx: txn,
              );
              for (final model in models) {
                await _weekRecordRepository.update(
                  model.copyWith(
                    status: ProgressStatus.inProgress,
                    currentDay: 1,
                    updatedAt: now,
                  ),
                  txn,
                );
              }
            }

            // Find first day of next week
            final nextWeekFirstDay = await _dayRecordRepository.selectMany(
              where:
                  '${MealPlanDayRecordColumns.mealPlanWeekRecordId.value} = ? AND ${MealPlanDayRecordColumns.day.value} = ?',
              whereArgs: [nextWeek.id!, 1],
              limit: 1,
              trx: txn,
            );
            if (nextWeekFirstDay.isNotEmpty) {
              {
                final models = await _dayRecordRepository.selectMany(
                  where: '${MealPlanDayRecordColumns.id.value} = ?',
                  whereArgs: [nextWeekFirstDay.first.id!],
                  trx: txn,
                );
                for (final model in models) {
                  await _dayRecordRepository.update(
                    model.copyWith(
                      status: ProgressStatus.inProgress,
                      updatedAt: now,
                    ),
                    txn,
                  );
                }
              }
            }

            {
              final models = await _recordRepository.selectMany(
                where: '${MealPlanRecordColumns.id.value} = ?',
                whereArgs: [recordId],
                trx: txn,
              );
              for (final model in models) {
                await _recordRepository.update(
                  model.copyWith(
                    currentWeek: nextWeek.week,
                    currentDay: 1,
                    updatedAt: now,
                  ),
                  txn,
                );
              }
            }
          } else {
            // Complete entire meal plan record!
            {
              final models = await _recordRepository.selectMany(
                where: '${MealPlanRecordColumns.id.value} = ?',
                whereArgs: [recordId],
                trx: txn,
              );
              for (final model in models) {
                await _recordRepository.update(
                  model.copyWith(
                    status: ProgressStatus.completed,
                    completedAt: Nullable(now),
                    updatedAt: now,
                  ),
                  txn,
                );
              }
            }
          }
        }

        // Reload record
        final updatedRecRows = await _recordRepository.selectMany(
          where: '${MealPlanRecordColumns.id.value} = ?',
          whereArgs: [recordId],
          trx: txn,
        );
        final updatedRecord = updatedRecRows.first;
        return ok(MealPlanRecordDto.fromModel(updatedRecord));
      });
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to complete current day', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to complete current day',
        ),
      );
    }
  }

  Future<
    Result<
      PaginatedDto<MealPlanRecordDto, MealPlanRecord>,
      ServiceError<OperationErrorTypes>
    >
  >
  getMealPlanRecords({
    int? mealPlanId,
    ProgressStatus? status,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting meal plan records');
    try {
      final where = WhereBuilder();
      if (mealPlanId != null) {
        where.and(MealPlanRecordColumns.mealPlanId.equal, mealPlanId);
      }
      if (status != null) {
        where.and(MealPlanRecordColumns.status.equal, status.value);
      }

      final records = await _recordRepository.selectPaginated(
        where: where.where,
        whereArgs: where.args,
        limit: limit,
        offset: offset,
        orderBy: [MealPlanRecordColumns.startedAt.orderDesc],
      );
      final total = await _recordRepository.count(
        where: where.where,
        whereArgs: where.args,
      );

      final List<MealPlanRecordDto> dtos = [];
      for (final r in records) {
        final plan = await _mealPlanRepository.selectOne(r.mealPlanId);
        dtos.add(
          MealPlanRecordDto.fromModel(
            r,
            planName: plan?.name,
            totalWeeks: plan?.totalWeeks ?? 1,
            totalDays: plan?.totalDays ?? 7,
          ),
        );
      }

      return ok(
        PaginatedDto<MealPlanRecordDto, MealPlanRecord>(
          data: dtos,
          total: total,
          limit: limit,
          offset: offset,
        ),
      );
    } catch (e) {
      _logger.severe('Failed to get meal plan records', e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get meal plan records',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> abandonMealPlan(
    int recordId,
  ) async {
    _logger.info('Abandoning meal plan record $recordId');
    try {
      final record = await _recordRepository.selectOne(recordId);
      if (record == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Meal plan record not found',
          ),
        );
      }

      final now = DateUtilities.getNowUtcUnix();
      final updated = record.copyWith(
        status: ProgressStatus.abandoned,
        completedAt: Nullable(now),
        updatedAt: now,
      );
      await _recordRepository.update(updated);
      return ok(null);
    } on ServiceError<SingleErrorTypes> catch (error) {
      return err(error);
    } catch (e) {
      _logger.severe('Failed to abandon meal plan record $recordId', e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to abandon meal plan record',
        ),
      );
    }
  }
}
