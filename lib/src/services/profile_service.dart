import '../models/db.dart';
import '../models/enums.dart';
import '../models/profile_model.dart';
import '../models/repository.dart';
import '../models/utilities.dart';

class ProfileService {
  ProfileService._();

  static final ProfileService _instance = ProfileService._();

  factory ProfileService() => _instance;

  final Repository<Profile> _repository = Repository<Profile>(
    databaseHelper: DatabaseHelper(),
    tableName: Profile.table,
    fromMap: (map) => Profile.fromMap(map),
  );

  Future<Profile> upsertProfile({
    required String name,
    required int height,
    required Gender gender,
  }) async {
    final Profile? existingProfile = await _repository.selectLatest();

    if (existingProfile != null) {
      final Profile updatedProfile = existingProfile.copyWith(
        name: name,
        height: height,
        gender: gender,
        updatedAt: DateUtilities.getNowUtcUnix(),
      );
      await _repository.update(updatedProfile);
      return updatedProfile;
    }

    final Profile profile = Profile.create(
      name,
      height,
      gender,
    );
    final int id = await _repository.insert(profile);
    return profile.copyWith(id: id);
  }

  Future<Profile> updateProfile({
    String? name,
    int? height,
    Gender? gender,
  }) async {
    final Profile? existingProfile = await _repository.selectLatest();

    if (existingProfile == null) {
      throw Exception('Profile does not exist');
    }

    final Profile updatedProfile = existingProfile.copyWith(
      name: name,
      height: height,
      gender: gender,
      updatedAt: DateUtilities.getNowUtcUnix(),
    );
    await _repository.update(updatedProfile);
    return updatedProfile;
  }

  Future<Profile?> selectLatest() async {
    return await _repository.selectLatest();
  }
}
