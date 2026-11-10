import '../../utils/nullable.dart';
import '../../data/utils/json_data.dart';

class EquipmentInput {
  final String name;
  final Nullable<PictureData> picture;
  final bool isFavorite;

  const EquipmentInput({
    required this.name,
    this.picture = const Nullable<PictureData>(null),
    this.isFavorite = false,
  });
}
