import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/common.dart';

class PictureDto extends Equatable {
  final PictureStorage storage;
  final String uri;

  const PictureDto({
    required this.storage,
    required this.uri,
  });

  factory PictureDto.fromModel(PictureData picture) {
    return PictureDto(
      storage: picture.storage,
      uri: picture.uri,
    );
  }

  PictureDto copyWith({
    PictureStorage? storage,
    String? uri,
  }) {
    return PictureDto(
      storage: storage ?? this.storage,
      uri: uri ?? this.uri,
    );
  }

  @override
  List<Object?> get props => [storage, uri];
}
