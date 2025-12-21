import '../models/db.dart';
import '../models/equipment_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';

class EquipmentService {
  EquipmentService._();

  static final EquipmentService instance = EquipmentService._();

  factory EquipmentService() => instance;

  final Repository<Equipment> _repository = Repository<Equipment>(
    databaseHelper: DatabaseHelper(),
    tableName: Equipment.table,
    fromMap: (map) => Equipment.fromMap(map),
  );

  Future<List<Equipment>> getEquipments({
    String? name,
    int? limit,
    int? offset,
  }) async {
    final WhereBuilder query = WhereBuilder();

    if (name != null) {
      query.add('name LIKE ?', '%$name%');
    }

    return await _repository.selectPaginated(
      limit: limit,
      offset: offset,
      where: query.where,
      whereArgs: query.args,
      orderBy: 'name ASC',
    );
  }

  Future<Equipment?> getEquipment(int id) async {
    return await _repository.selectOne(id);
  }

  Future<Equipment> createEquipment({
    required String name,
    String? pictureUri,
  }) async {
    final Equipment equipment = Equipment.create(
      name,
      pictureUri,
    );
    final int id = await _repository.insert(equipment);
    return equipment.copyWith(id: id);
  }

  Future<void> createEquipments(List<Equipment> equipments) async {
    await _repository.insertMany(equipments);
  }

  Future<bool> deleteEquipment(int id) async {
    return await _repository.deleteOne(id);
  }

  Future<Equipment> updateEquipment(
    int id, {
    String? name,
    String? pictureUri,
  }) async {
    final Equipment? equipment = await _repository.selectOne(id);
    if (equipment == null) {
      throw Exception('Equipment does not exist');
    }

    final Equipment updatedEquipment = equipment.copyWith(
      name: name,
      pictureUri: pictureUri,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedEquipment);

    return updatedEquipment;
  }
}

