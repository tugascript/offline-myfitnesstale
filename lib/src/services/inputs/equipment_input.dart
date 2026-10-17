import '../../common/nullable.dart';
import '../../models/common.dart';

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
