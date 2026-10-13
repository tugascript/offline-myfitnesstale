import 'package:logging/logging.dart';

import '../common/nullable.dart';
import '../models/daily_nutrition_log_model.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/meal_log_model.dart';
import '../models/meal_plan_day_model.dart';
import '../models/meal_plan_day_record_model.dart';
import '../models/meal_plan_model.dart';
import '../models/meal_plan_record_model.dart';
import '../models/meal_plan_week_model.dart';
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
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Meal plan not found',
        ));
      }

      final int targetVersion = version ?? plan.version;
      final startDt = startDate ?? DateTime.now();
      final baseDate = DateTime(startDt.year, startDt.month, startDt.day);
      final int startUnix = DateUtilities.getDateUnix(baseDate);

      final db = await DatabaseHelper().db;
      return await db.transaction<
          Result<MealPlanRecordDto, ServiceError<SingleErrorTypes>>>(
        (txn) async {
          // 1. Abandon existing in-progress meal plan record
          await txn.update(
            MealPlanRecord.table,
            {
              MealPlanRecordColumns.status.value:
                  ProgressStatus.abandoned.value,
              MealPlanRecordColumns.completedAt.value:
                  DateUtilities.getNowUtcUnix(),
              MealPlanRecordColumns.updatedAt.value:
                  DateUtilities.getNowUtcUnix(),
            },
            where: '${MealPlanRecordColumns.status.value} = ?',
            whereArgs: [ProgressStatus.inProgress.value],
          );

          // 2. Load plan's weeks and days for targetVersion
          final weekRows = await txn.query(
            MealPlanWeek.table,
            where:
                '${MealPlanWeekColumns.mealPlanId.value} = ? AND ${MealPlanWeekColumns.planVersion.value} = ?',
            whereArgs: [mealPlanId, targetVersion],
            orderBy: '${MealPlanWeekColumns.weekNumber.value} ASC',
          );

          if (weekRows.isEmpty) {
            return err(const ServiceError(
              type: SingleErrorTypes.invalidInput,
              description: 'Meal plan has no configured weeks',
            ));
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
            final w = MealPlanWeek.fromMap(wRow);

            final weekRecord = MealPlanWeekRecord.create(
              mealPlanRecordId: recordId,
              mealPlanWeekId: w.id!,
              week: w.weekNumber,
              status: ProgressStatus.inProgress,
              currentDay: 1,
            );
            final int weekRecordId =
                await _weekRecordRepository.insert(weekRecord, txn);

            final dayRows = await txn.query(
              MealPlanDay.table,
              where: '${MealPlanDayColumns.mealPlanWeekId.value} = ?',
              whereArgs: [w.id!],
              orderBy: '${MealPlanDayColumns.day.value} ASC',
            );

            final List<MealPlanDayRecordDto> dayRecordDtos = [];

            for (final dRow in dayRows) {
              final d = MealPlanDay.fromMap(dRow);

              // Compute calendar date for this week and day
              final int offsetDays = (w.weekNumber - 1) * 7 + (d.day - 1);
              final DateTime dayCalendarDate =
                  baseDate.add(Duration(days: offsetDays));
              final int numericDate =
                  DateUtilities.getNumericDate(dayCalendarDate);

              // Get or create DailyNutritionLog for that calendar day
              final existingLogRows = await txn.query(
                DailyNutritionLog.table,
                where: '${DailyNutritionLogColumns.date.value} = ?',
                whereArgs: [numericDate],
                limit: 1,
              );

              int dailyLogId;
              if (existingLogRows.isNotEmpty) {
                dailyLogId = existingLogRows
                    .first[DailyNutritionLogColumns.id.value] as int;
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
              final int dayRecordId =
                  await _dayRecordRepository.insert(dayRecord, txn);

              dayRecordDtos.add(MealPlanDayRecordDto.fromModel(
                dayRecord.copyWith(id: Nullable(dayRecordId)),
              ));
            }

            weekRecordDtos.add(MealPlanWeekRecordDto.fromModel(
              weekRecord.copyWith(id: Nullable(weekRecordId)),
              days: dayRecordDtos,
            ));
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
        },
      );
    } catch (e) {
      _logger.severe('Failed to start meal plan $mealPlanId', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to start meal plan',
      ));
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
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'No active meal plan record',
        ));
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
        weekDtos.add(MealPlanWeekRecordDto.fromModel(
          wRec,
          days:
              dayRecords.map((d) => MealPlanDayRecordDto.fromModel(d)).toList(),
        ));
      }

      return ok(MealPlanRecordDto.fromModel(
        active,
        planName: plan?.name,
        totalWeeks: plan?.totalWeeks ?? 1,
        totalDays: plan?.totalDays ?? 7,
        weeks: weekDtos,
      ));
    } catch (e) {
      _logger.severe('Failed to get active meal plan record', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to get active meal plan record',
      ));
    }
  }

  Future<Result<MealPlanRecordDto, ServiceError<SingleErrorTypes>>>
      completeCurrentDay({
    required int recordId,
  }) async {
    _logger.info('Completing current day for meal plan record $recordId');
    try {
      final db = await DatabaseHelper().db;
      return await db.transaction<
          Result<MealPlanRecordDto, ServiceError<SingleErrorTypes>>>(
        (txn) async {
          final recordRows = await txn.query(
            MealPlanRecord.table,
            where: '${MealPlanRecordColumns.id.value} = ?',
            whereArgs: [recordId],
            limit: 1,
          );
          if (recordRows.isEmpty) {
            return err(const ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Meal plan record not found',
            ));
          }
          final record = MealPlanRecord.fromMap(recordRows.first);
          if (record.status != ProgressStatus.inProgress) {
            return err(const ServiceError(
              type: SingleErrorTypes.invalidInput,
              description: 'Record is not currently in progress',
            ));
          }

          // Find current week record
          final weekRecRows = await txn.query(
            MealPlanWeekRecord.table,
            where:
                '${MealPlanWeekRecordColumns.mealPlanRecordId.value} = ? AND ${MealPlanWeekRecordColumns.week.value} = ?',
            whereArgs: [recordId, record.currentWeek],
            limit: 1,
          );
          if (weekRecRows.isEmpty) {
            return err(const ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Current week record not found',
            ));
          }
          final currentWeekRec = MealPlanWeekRecord.fromMap(weekRecRows.first);

          // Find current day record
          final dayRecRows = await txn.query(
            MealPlanDayRecord.table,
            where:
                '${MealPlanDayRecordColumns.mealPlanWeekRecordId.value} = ? AND ${MealPlanDayRecordColumns.day.value} = ?',
            whereArgs: [currentWeekRec.id!, record.currentDay],
            limit: 1,
          );
          if (dayRecRows.isEmpty) {
            return err(const ServiceError(
              type: SingleErrorTypes.notFound,
              description: 'Current day record not found',
            ));
          }
          final currentDayRec = MealPlanDayRecord.fromMap(dayRecRows.first);

          // Roll up logged totals from DailyNutritionLog
          final mealLogRows = await txn.query(
            MealLog.table,
            where: '${MealLogColumns.dailyLogId.value} = ?',
            whereArgs: [currentDayRec.dailyLogId],
          );

          int dayCals = 0;
          int dayProtein = 0;
          int dayCarbs = 0;
          int dayFat = 0;
          int dayFiber = 0;

          for (final mRow in mealLogRows) {
            final m = MealLog.fromMap(mRow);
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
          await txn.update(
            MealPlanDayRecord.table,
            updatedDay.toMap(),
            where: '${MealPlanDayRecordColumns.id.value} = ?',
            whereArgs: [updatedDay.id!],
          );

          // Check if there is another day in this week
          final allDaysInWeekRows = await txn.query(
            MealPlanDayRecord.table,
            where: '${MealPlanDayRecordColumns.mealPlanWeekRecordId.value} = ?',
            whereArgs: [currentWeekRec.id!],
            orderBy: '${MealPlanDayRecordColumns.day.value} ASC',
          );
          final allDaysInWeek = allDaysInWeekRows
              .map((r) => MealPlanDayRecord.fromMap(r))
              .toList();

          final nextDay =
              allDaysInWeek.where((d) => d.day > record.currentDay).firstOrNull;

          if (nextDay != null) {
            // Advance day in same week
            await txn.update(
              MealPlanDayRecord.table,
              {
                MealPlanDayRecordColumns.status.value:
                    ProgressStatus.inProgress.value,
                MealPlanDayRecordColumns.updatedAt.value: now,
              },
              where: '${MealPlanDayRecordColumns.id.value} = ?',
              whereArgs: [nextDay.id!],
            );

            await txn.update(
              MealPlanWeekRecord.table,
              {
                MealPlanWeekRecordColumns.currentDay.value: nextDay.day,
                MealPlanWeekRecordColumns.updatedAt.value: now,
              },
              where: '${MealPlanWeekRecordColumns.id.value} = ?',
              whereArgs: [currentWeekRec.id!],
            );

            await txn.update(
              MealPlanRecord.table,
              {
                MealPlanRecordColumns.currentDay.value: nextDay.day,
                MealPlanRecordColumns.updatedAt.value: now,
              },
              where: '${MealPlanRecordColumns.id.value} = ?',
              whereArgs: [recordId],
            );
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

            await txn.update(
              MealPlanWeekRecord.table,
              {
                MealPlanWeekRecordColumns.status.value:
                    ProgressStatus.completed.value,
                MealPlanWeekRecordColumns.completedAt.value: now,
                MealPlanWeekRecordColumns.totalCalories.value: weekCals,
                MealPlanWeekRecordColumns.totalProtein.value: weekProtein,
                MealPlanWeekRecordColumns.totalCarbs.value: weekCarbs,
                MealPlanWeekRecordColumns.totalFat.value: weekFat,
                MealPlanWeekRecordColumns.totalFiber.value: weekFiber,
                MealPlanWeekRecordColumns.updatedAt.value: now,
              },
              where: '${MealPlanWeekRecordColumns.id.value} = ?',
              whereArgs: [currentWeekRec.id!],
            );

            // Check if there is a next week
            final allWeeksRows = await txn.query(
              MealPlanWeekRecord.table,
              where: '${MealPlanWeekRecordColumns.mealPlanRecordId.value} = ?',
              whereArgs: [recordId],
              orderBy: '${MealPlanWeekRecordColumns.week.value} ASC',
            );
            final allWeeks =
                allWeeksRows.map((r) => MealPlanWeekRecord.fromMap(r)).toList();

            final nextWeek =
                allWeeks.where((w) => w.week > record.currentWeek).firstOrNull;

            if (nextWeek != null) {
              // Advance to next week
              await txn.update(
                MealPlanWeekRecord.table,
                {
                  MealPlanWeekRecordColumns.status.value:
                      ProgressStatus.inProgress.value,
                  MealPlanWeekRecordColumns.currentDay.value: 1,
                  MealPlanWeekRecordColumns.updatedAt.value: now,
                },
                where: '${MealPlanWeekRecordColumns.id.value} = ?',
                whereArgs: [nextWeek.id!],
              );

              // Find first day of next week
              final nextWeekFirstDay = await txn.query(
                MealPlanDayRecord.table,
                where:
                    '${MealPlanDayRecordColumns.mealPlanWeekRecordId.value} = ? AND ${MealPlanDayRecordColumns.day.value} = ?',
                whereArgs: [nextWeek.id!, 1],
                limit: 1,
              );
              if (nextWeekFirstDay.isNotEmpty) {
                await txn.update(
                  MealPlanDayRecord.table,
                  {
                    MealPlanDayRecordColumns.status.value:
                        ProgressStatus.inProgress.value,
                    MealPlanDayRecordColumns.updatedAt.value: now,
                  },
                  where: '${MealPlanDayRecordColumns.id.value} = ?',
                  whereArgs: [
                    nextWeekFirstDay.first[MealPlanDayRecordColumns.id.value],
                  ],
                );
              }

              await txn.update(
                MealPlanRecord.table,
                {
                  MealPlanRecordColumns.currentWeek.value: nextWeek.week,
                  MealPlanRecordColumns.currentDay.value: 1,
                  MealPlanRecordColumns.updatedAt.value: now,
                },
                where: '${MealPlanRecordColumns.id.value} = ?',
                whereArgs: [recordId],
              );
            } else {
              // Complete entire meal plan record!
              await txn.update(
                MealPlanRecord.table,
                {
                  MealPlanRecordColumns.status.value:
                      ProgressStatus.completed.value,
                  MealPlanRecordColumns.completedAt.value: now,
                  MealPlanRecordColumns.updatedAt.value: now,
                },
                where: '${MealPlanRecordColumns.id.value} = ?',
                whereArgs: [recordId],
              );
            }
          }

          // Reload record
          final updatedRecRows = await txn.query(
            MealPlanRecord.table,
            where: '${MealPlanRecordColumns.id.value} = ?',
            whereArgs: [recordId],
          );
          final updatedRecord = MealPlanRecord.fromMap(updatedRecRows.first);
          return ok(MealPlanRecordDto.fromModel(updatedRecord));
        },
      );
    } catch (e) {
      _logger.severe('Failed to complete current day', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to complete current day',
      ));
    }
  }

  Future<
      Result<PaginatedDto<MealPlanRecordDto, MealPlanRecord>,
          ServiceError<OperationErrorTypes>>> getMealPlanRecords({
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
        dtos.add(MealPlanRecordDto.fromModel(
          r,
          planName: plan?.name,
          totalWeeks: plan?.totalWeeks ?? 1,
          totalDays: plan?.totalDays ?? 7,
        ));
      }

      return ok(PaginatedDto<MealPlanRecordDto, MealPlanRecord>(
        data: dtos,
        total: total,
        limit: limit,
        offset: offset,
      ));
    } catch (e) {
      _logger.severe('Failed to get meal plan records', e);
      return err(const ServiceError(
        type: OperationErrorTypes.operationFailure,
        description: 'Failed to get meal plan records',
      ));
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> abandonMealPlan(
    int recordId,
  ) async {
    _logger.info('Abandoning meal plan record $recordId');
    try {
      final record = await _recordRepository.selectOne(recordId);
      if (record == null) {
        return err(const ServiceError(
          type: SingleErrorTypes.notFound,
          description: 'Meal plan record not found',
        ));
      }

      final now = DateUtilities.getNowUtcUnix();
      final updated = record.copyWith(
        status: ProgressStatus.abandoned,
        completedAt: Nullable(now),
        updatedAt: now,
      );
      await _recordRepository.update(updated);
      return ok(null);
    } catch (e) {
      _logger.severe('Failed to abandon meal plan record $recordId', e);
      return err(const ServiceError(
        type: SingleErrorTypes.operationFailure,
        description: 'Failed to abandon meal plan record',
      ));
    }
  }
}
