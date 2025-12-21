import '../models/db.dart';


class DataInitService {
  DataInitService._();
  
  static final DataInitService _instance = DataInitService._();
  
  factory DataInitService() => _instance;

  final _dbHelper = DatabaseHelper();

  Future<void> loadDefaultData({
    required bool withWorkouts,
  }) async {
    return await _dbHelper.createDefaultData(withWorkouts: withWorkouts);
  }
}