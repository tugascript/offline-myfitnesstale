import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import '../common/nullable.dart';
import '../models/db.dart';
import '../models/enums.dart';
import '../models/equipment_model.dart';
import '../models/exercise_equipment_model.dart';
import '../models/exercise_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';
import 'common/errors.dart';
import 'common/result.dart';
import 'dtos/equipment_dto.dart';
import 'dtos/exercise_dto.dart';
import 'dtos/paginated_dto.dart';
import 'inputs/equipment_input.dart';
import 'inputs/exercise_input.dart';

class ExerciseService {
  ExerciseService._();

  static final ExerciseService instance = ExerciseService._();

  factory ExerciseService() => instance;

  final Logger _logger = Logger("Exercise Service");

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final _repository = Repository<Exercise>(
    databaseHelper: DatabaseHelper(),
    tableName: Exercise.table,
    fromMap: Exercise.fromMap,
  );

  final _equipmentRepository = Repository<Equipment>(
    databaseHelper: DatabaseHelper(),
    tableName: Equipment.table,
    fromMap: Equipment.fromMap,
  );

  final _exerciseEquipmentRepository =
      JoinRepository<ExerciseEquipment, Equipment, Exercise>(
        databaseHelper: DatabaseHelper(),
        tableName: ExerciseEquipment.table,
        fromMap: ExerciseEquipment.fromMap,
        primaryKeys: ExerciseEquipment.primaryKeys,
        joinTableName: Equipment.table,
        joinFromMap: Equipment.fromMap,
        reverseTableName: Exercise.table,
        reverseFromMap: Exercise.fromMap,
      );

  Future<
    Result<
      PaginatedDto<ExerciseDto, Exercise>,
      ServiceError<OperationErrorTypes>
    >
  >
  getExercises({
    String? name,
    MuscleGroup? muscleGroup,
    Difficulty? difficulty,
    int? equipmentId,
    bool isFavorite = false,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info("Getting exercises...");
    final WhereBuilder query = WhereBuilder();

    if (name != null && name.isNotEmpty) {
      query.and(ExerciseColumns.name.like, '%$name%');
    }
    if (muscleGroup != null) {
      query.and(ExerciseColumns.muscleGroup.equal, muscleGroup.value);
    }
    if (isFavorite) {
      query.and(ExerciseColumns.isFavorite.equal, 1);
    }
    if (difficulty != null) {
      query.and(ExerciseColumns.difficulty.equal, difficulty.value);
    }
    if (equipmentId != null) {
      query.and(
        '${ExerciseColumns.id.value} IN ('
        'SELECT ${ExerciseEquipmentColumns.exerciseId.value} '
        'FROM ${ExerciseEquipment.table} '
        'WHERE ${ExerciseEquipmentColumns.equipmentId.equal}'
        ')',
        equipmentId,
      );
    }

    try {
      final List<Exercise> exercises = await _repository.selectPaginated(
        limit: limit,
        offset: offset,
        where: query.where,
        whereArgs: query.args,
        orderBy: [ExerciseColumns.name.orderCaseInsensitiveAsc],
      );
      final int total = await _repository.count(
        where: query.where,
        whereArgs: query.args,
      );
      _logger.info("Found ${exercises.length} exercises");
      return ok(
        PaginatedDto<ExerciseDto, Exercise>.mapData(
          data: exercises,
          mapper: (e) => ExerciseDto.fromModel(e),
          limit: limit,
          offset: offset,
          total: total,
        ),
      );
    } catch (e) {
      _logger.severe("Failed to get exercises", e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get exercises',
        ),
      );
    }
  }

  Future<Result<List<ExerciseDto>, ServiceError<OperationErrorTypes>>>
  getAllExercises({
    MuscleGroup? muscleGroup,
    String name = "",
    bool isFavorite = false,
  }) async {
    _logger.info("Getting all exercises...");
    final WhereBuilder query = WhereBuilder();

    if (name.isNotEmpty) {
      query.and(ExerciseColumns.name.like, '%$name%');
    }
    if (muscleGroup != null) {
      query.and(ExerciseColumns.muscleGroup.equal, muscleGroup.value);
    }
    if (isFavorite) {
      query.and(ExerciseColumns.isFavorite.equal, 1);
    }

    try {
      final List<Exercise> exercises = await _repository.selectMany(
        where: query.where,
        whereArgs: query.args,
        orderBy: [ExerciseColumns.name.orderCaseInsensitiveAsc],
      );
      _logger.info("Found ${exercises.length} exercises");
      return ok(exercises.map((e) => ExerciseDto.fromModel(e)).toList());
    } catch (e) {
      _logger.severe("Failed to get all exercises", e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get all exercises',
        ),
      );
    }
  }

  Future<Result<ExerciseDto, ServiceError<SingleErrorTypes>>> getExercise(
    int id,
  ) async {
    _logger.info("Getting exercise with id: $id");
    try {
      final Exercise? exercise = await _repository.selectOne(id);
      if (exercise == null) {
        _logger.info("Exercise with id: $id not found");
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise not found',
          ),
        );
      }

      _logger.info(
        "Found exercise with id: $id, Getting the equipments for the exercise",
      );
      final List<Equipment> equipments = await _exerciseEquipmentRepository
          .selectJoined(id);
      _logger.info("Found ${equipments.length} equipments");

      return ok(
        ExerciseDto.fromModel(
          exercise,
          equipments: equipments.map((e) => EquipmentDto.fromModel(e)).toList(),
        ),
      );
    } catch (e) {
      _logger.severe("Failed to get exercise with id: $id", e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get exercise',
        ),
      );
    }
  }

  Future<Map<int, Exercise>> getExercisesByIdsLoader(List<int> ids) async {
    final WhereBuilder query = WhereBuilder();
    query.and('${ExerciseColumns.id.value} IN (${ids.join(',')})');

    final List<Exercise> exercises = await _repository.selectMany(
      where: query.where,
      whereArgs: query.args,
    );

    return {for (final Exercise e in exercises) e.id!: e};
  }

  Future<Result<ExerciseDto, ServiceError<SingleErrorTypes>>> createExercise(
    ExerciseInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    _logger.info("Creating exercise with name: ${input.name}");
    final Exercise exercise = Exercise.create(
      name: input.name,
      muscleGroup: input.muscleGroup,
      muscles: input.muscles,
      description: input.description.value,
      picture: input.picture.value,
      video: input.video.value,
      isFavorite: input.isFavorite,
      difficulty: input.difficulty.value,
      createdBy: createdBy,
    );

    try {
      if (input.equipmentIds.isEmpty) {
        final id = await _repository.insert(exercise);
        return ok(
          ExerciseDto.fromModel(
            exercise.copyWith(id: Nullable(id)),
            equipments: const [],
          ),
        );
      }

      final List<Equipment> equipments = await _equipmentRepository.selectMany(
        where: EquipmentColumns.id.inList(input.equipmentIds.length),
        whereArgs: input.equipmentIds.toList(),
      );
      if (equipments.length != input.equipmentIds.length) {
        _logger.info(
          "Not all equipments were found, ${equipments.length} equipments found, ${input.equipmentIds.length} equipments expected",
        );
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Not all equipments were found',
          ),
        );
      }

      final int id = await (await _databaseHelper.db).transaction((txn) async {
        final int exerciseId = await _repository.insert(exercise, txn);
        final List<ExerciseEquipment> exerciseEquipments = input.equipmentIds
            .map(
              (e) => ExerciseEquipment.create(
                exerciseId: exerciseId,
                equipmentId: e,
              ),
            )
            .toList();
        await _exerciseEquipmentRepository.insertMany(exerciseEquipments, txn);
        return exerciseId;
      });
      _logger.info("Created exercise with id: $id");
      return ok(
        ExerciseDto.fromModel(
          exercise.copyWith(id: Nullable(id)),
          equipments: equipments.map((e) => EquipmentDto.fromModel(e)).toList(),
        ),
      );
    } catch (e) {
      _logger.severe("Failed to create exercise", e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to create exercise',
        ),
      );
    }
  }

  Future<Result<List<ExerciseDto>, ServiceError<OperationErrorTypes>>>
  createExercises(
    List<ExerciseInput> exerciseInputs, {
    CreatedBy createdBy = CreatedBy.user,
    Transaction? transaction,
  }) async {
    _logger.info("Creating ${exerciseInputs.length} exercises...");
    try {
      Future<List<ExerciseDto>> create(Transaction txn) async {
        final List<ExerciseDto> exercises = [];
        final Set<int> allEquipmentIds = {
          for (final input in exerciseInputs) ...input.equipmentIds,
        };
        final Map<int, EquipmentDto> equipmentMap = {};
        if (allEquipmentIds.isNotEmpty) {
          final fetched = await _equipmentRepository.selectMany(
            where: EquipmentColumns.id.inList(allEquipmentIds.length),
            whereArgs: allEquipmentIds.toList(),
            trx: txn,
          );
          for (final eq in fetched) {
            equipmentMap[eq.id!] = EquipmentDto.fromModel(eq);
          }
        }

        for (final exerciseInput in exerciseInputs) {
          final exercise = Exercise.create(
            name: exerciseInput.name,
            muscleGroup: exerciseInput.muscleGroup,
            muscles: exerciseInput.muscles,
            description: exerciseInput.description.value,
            picture: exerciseInput.picture.value,
            video: exerciseInput.video.value,
            difficulty: exerciseInput.difficulty.value,
            isFavorite: exerciseInput.isFavorite,
            createdBy: createdBy,
          );
          final id = await _repository.insert(exercise, txn);

          if (exerciseInput.equipmentIds.isEmpty) {
            exercises.add(
              ExerciseDto.fromModel(exercise.copyWith(id: Nullable(id))),
            );
            continue;
          }

          final List<EquipmentDto> equipments = [];
          for (final equipmentId in exerciseInput.equipmentIds) {
            final exerciseEquipment = ExerciseEquipment.create(
              equipmentId: equipmentId,
              exerciseId: id,
            );
            await _exerciseEquipmentRepository.insert(exerciseEquipment, txn);
            final eqDto = equipmentMap[equipmentId];
            if (eqDto != null) {
              equipments.add(eqDto);
            }
          }

          exercises.add(
            ExerciseDto.fromModel(
              exercise.copyWith(id: Nullable(id)),
              equipments: equipments,
            ),
          );
        }

        return exercises;
      }

      final List<ExerciseDto> exercises = transaction != null
          ? await create(transaction)
          : await (await _databaseHelper.db).transaction(create);

      return ok(exercises);
    } catch (e) {
      _logger.severe("Failed to creates exercises", e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to create exercises',
        ),
      );
    }
  }

  Future<Result<ExerciseDto, ServiceError<SingleErrorTypes>>> updateExercise(
    int id,
    ExerciseInput input,
  ) async {
    _logger.info("Updating exercise with id: $id");
    try {
      final Exercise? exercise = await _repository.selectOne(id);
      if (exercise == null) {
        _logger.info("Exercise with id: $id not found");
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise not found',
          ),
        );
      }

      final Exercise updatedExercise = exercise.copyWith(
        name: input.name,
        description: input.description,
        muscles: input.muscles,
        muscleGroup: input.muscleGroup,
        picture: input.picture,
        video: input.video,
        isFavorite: input.isFavorite,
        difficulty: input.difficulty,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );

      if (input.equipmentIds.isEmpty) {
        await _repository.startTransaction((txn) async {
          await _repository.update(updatedExercise, txn);
          await _exerciseEquipmentRepository.deleteAllByPk1(id, txn);
        });
        _logger.info("Updated exercise with id: $id");
        return ok(ExerciseDto.fromModel(updatedExercise, equipments: const []));
      }

      final List<Equipment> equipments = await _equipmentRepository.selectMany(
        where: EquipmentColumns.id.inList(input.equipmentIds.length),
        whereArgs: input.equipmentIds.toList(),
      );
      if (equipments.length != input.equipmentIds.length) {
        _logger.info(
          "Not all equipments were found, ${equipments.length} equipments found, ${input.equipmentIds.length} equipments expected",
        );
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Not all equipments were found',
          ),
        );
      }

      await _repository.startTransaction((txn) async {
        await _repository.update(updatedExercise, txn);
        await _exerciseEquipmentRepository.deleteAllByPk1(id, txn);
        await _exerciseEquipmentRepository.insertMany(
          input.equipmentIds
              .map(
                (e) => ExerciseEquipment.create(exerciseId: id, equipmentId: e),
              )
              .toList(),
          txn,
        );
      });

      return ok(
        ExerciseDto.fromModel(
          updatedExercise,
          equipments: equipments.map((e) => EquipmentDto.fromModel(e)).toList(),
        ),
      );
    } catch (e) {
      _logger.severe("Failed to update exercise with id: $id", e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update exercise',
        ),
      );
    }
  }

  Future<Result<ExerciseDto, ServiceError<SingleErrorTypes>>>
  updateExerciseFavorite(int id, bool isFavorite) async {
    _logger.info("Updating exercise favorite with id: $id");
    try {
      final Exercise? exercise = await _repository.selectOne(id);
      if (exercise == null) {
        _logger.info("Exercise with id: $id not found");
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise not found',
          ),
        );
      }

      final Exercise updatedExercise = exercise.copyWith(
        isFavorite: isFavorite,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedExercise);
      final List<Equipment> equipments = await _exerciseEquipmentRepository
          .selectJoined(id);
      return ok(
        ExerciseDto.fromModel(
          updatedExercise,
          equipments: equipments.map((e) => EquipmentDto.fromModel(e)).toList(),
        ),
      );
    } catch (e) {
      _logger.severe("Failed to update exercise favorite with id: $id", e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update exercise favorite',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteExercise(
    int id,
  ) async {
    _logger.info("Deleting exercise with id: $id");

    try {
      final bool deleted = await _repository.deleteOne(id);
      if (!deleted) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Exercise not found',
          ),
        );
      }

      _logger.info("Exercise with id: $id deleted successfully");
      return ok(null);
    } catch (e) {
      _logger.severe("Failed to delete exercise with id: $id", e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete exercise',
        ),
      );
    }
  }

  Future<
    Result<
      PaginatedDto<EquipmentDto, Equipment>,
      ServiceError<OperationErrorTypes>
    >
  >
  getEquipments({
    String? name,
    int limit = kDefaultLimit,
    int offset = kDefaultOffset,
  }) async {
    _logger.info('Getting equipments');
    final WhereBuilder query = WhereBuilder();

    if (name != null && name.isNotEmpty) {
      query.and(EquipmentColumns.name.like, '%$name%');
    }

    try {
      final List<Equipment> equipments = await _equipmentRepository
          .selectPaginated(
            limit: limit,
            offset: offset,
            where: query.where,
            whereArgs: query.args,
            orderBy: [EquipmentColumns.name.orderCaseInsensitiveAsc],
          );
      final int total = await _equipmentRepository.count(
        where: query.where,
        whereArgs: query.args,
      );
      _logger.info('Got ${equipments.length} equipments');
      return ok(
        PaginatedDto<EquipmentDto, Equipment>.mapData(
          data: equipments,
          mapper: (equipment) => EquipmentDto.fromModel(equipment),
          total: total,
          limit: limit,
          offset: offset,
        ),
      );
    } catch (e) {
      _logger.severe("Failed to get equipments", e.toString());
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get equipments',
        ),
      );
    }
  }

  Future<Result<List<EquipmentDto>, ServiceError<OperationErrorTypes>>>
  getAllEquipments() async {
    _logger.info('Getting all equipments');
    try {
      final List<Equipment> equipments = await _equipmentRepository.selectMany(
        orderBy: [EquipmentColumns.name.orderCaseInsensitiveAsc],
      );
      _logger.info('Got ${equipments.length} equipments');
      return ok(
        equipments
            .map((equipment) => EquipmentDto.fromModel(equipment))
            .toList(),
      );
    } catch (e) {
      _logger.severe("Failed to get all equipments", e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to get all equipments',
        ),
      );
    }
  }

  Future<Result<EquipmentDto, ServiceError<SingleErrorTypes>>> getEquipment(
    int id,
  ) async {
    _logger.info('Getting equipment with id $id');

    try {
      final Equipment? equipment = await _equipmentRepository.selectOne(id);
      if (equipment == null) {
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Equipment not found',
          ),
        );
      }

      _logger.info('Got equipment with id $id');
      return ok(EquipmentDto.fromModel(equipment));
    } catch (e) {
      _logger.severe("Failed to get equipment with id $id", e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get equipment',
        ),
      );
    }
  }

  Future<Result<EquipmentDto, ServiceError<OperationErrorTypes>>>
  createEquipment(
    EquipmentInput input, [
    CreatedBy createdBy = CreatedBy.user,
  ]) async {
    _logger.info('Creating equipment with name ${input.name}');
    final Equipment equipment = Equipment.create(
      name: input.name,
      picture: input.picture.value,
      isFavorite: input.isFavorite,
      createdBy: createdBy,
    );

    try {
      final int id = await _equipmentRepository.insert(equipment);
      return ok(EquipmentDto.fromModel(equipment.copyWith(id: Nullable(id))));
    } catch (e) {
      _logger.severe("Failed to create equipment with name ${input.name}", e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to create equipment',
        ),
      );
    }
  }

  Future<Result<int, ServiceError<OperationErrorTypes>>>
  countEquipments() async {
    _logger.info('Counting equipments');
    try {
      final int count = await _equipmentRepository.count();
      _logger.info('Counted $count equipments');
      return ok(count);
    } catch (e) {
      _logger.severe("Failed to count equipments", e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to count equipments',
        ),
      );
    }
  }

  Future<Result<List<EquipmentDto>, ServiceError<OperationErrorTypes>>>
  createEquipments(
    List<String> names, {
    CreatedBy createdBy = CreatedBy.user,
    Transaction? transaction,
  }) async {
    _logger.info('Creating ${names.length} equipments...');
    try {
      Future<List<Equipment>> create(Transaction txn) async {
        final List<Equipment> equipments = [];

        for (final name in names) {
          final equipment = Equipment.create(name: name, createdBy: createdBy);
          final id = await _equipmentRepository.insert(equipment, txn);
          equipments.add(equipment.copyWith(id: Nullable(id)));
        }

        return equipments;
      }

      final List<Equipment> equipments = transaction != null
          ? await create(transaction)
          : await (await _databaseHelper.db).transaction(create);

      _logger.info('Created ${equipments.length} equipments');
      return ok(equipments.map((e) => EquipmentDto.fromModel(e)).toList());
    } catch (e) {
      _logger.severe("Failed to create equipments", e);
      return err(
        const ServiceError(
          type: OperationErrorTypes.operationFailure,
          description: 'Failed to create equipments',
        ),
      );
    }
  }

  Future<Result<void, ServiceError<SingleErrorTypes>>> deleteEquipment(
    int id,
  ) async {
    _logger.info('Deleting equipment with id: $id');
    try {
      final deleted = await _equipmentRepository.deleteOne(id);
      if (!deleted) {
        _logger.info('Equipment with id: $id not found');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Equipment not found',
          ),
        );
      }

      _logger.info('Deleted equipment with id: $id');
      return ok(null);
    } catch (e) {
      _logger.severe("Failed to delete equipment with id: $id", e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to delete equipment',
        ),
      );
    }
  }

  Future<Result<EquipmentDto, ServiceError<SingleErrorTypes>>> updateEquipment(
    int id,
    EquipmentInput input,
  ) async {
    _logger.info('Updating equipment with id: $id');
    try {
      final Equipment? equipment = await _equipmentRepository.selectOne(id);
      if (equipment == null) {
        _logger.info('Equipment with id: $id not found');
        return err(
          const ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Equipment not found',
          ),
        );
      }

      final Equipment updatedEquipment = equipment.copyWith(
        name: input.name,
        picture: input.picture,
        isFavorite: input.isFavorite,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _equipmentRepository.update(updatedEquipment);
      _logger.info('Updated equipment with id: $id');
      return ok(EquipmentDto.fromModel(updatedEquipment));
    } catch (e) {
      _logger.severe("Failed to update equipment with id: $id", e);
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to update equipment',
        ),
      );
    }
  }

  Future<Result<List<ExerciseDto>, ServiceError<SingleErrorTypes>>>
  getExercisesByEquipmentId(int equipmentId) async {
    _logger.info('Getting exercises for equipment with id: $equipmentId');
    try {
      final Equipment? equipment = await _equipmentRepository.selectOne(
        equipmentId,
      );
      if (equipment == null) {
        _logger.info('Equipment with id: $equipmentId not found');
        return err(
          ServiceError(
            type: SingleErrorTypes.notFound,
            description: 'Equipment with id: $equipmentId not found',
          ),
        );
      }

      final List<Exercise> exercises = await _exerciseEquipmentRepository
          .selectReverseJoined(equipmentId, [
            ExerciseColumns.name.orderCaseInsensitiveAsc,
          ]);
      _logger.info(
        'Got ${exercises.length} exercises for equipment with id: $equipmentId',
      );
      return ok(exercises.map((e) => ExerciseDto.fromModel(e)).toList());
    } catch (e) {
      _logger.severe(
        "Failed to get exercises for equipment with id: $equipmentId",
        e,
      );
      return err(
        const ServiceError(
          type: SingleErrorTypes.operationFailure,
          description: 'Failed to get exercises for equipment',
        ),
      );
    }
  }
}
