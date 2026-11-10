import 'package:equatable/equatable.dart';

import '../../../utils/enums.dart';
import '../../../utils/json_data.dart';

final class VideoDto extends Equatable {
  final String uri;
  final VideoPlatform platform;

  const VideoDto({required this.uri, required this.platform});

  factory VideoDto.fromModel(VideoData video) {
    return VideoDto(uri: video.uri, platform: video.platform);
  }

  VideoDto copyWith({String? uri, VideoPlatform? platform}) {
    return VideoDto(uri: uri ?? this.uri, platform: platform ?? this.platform);
  }

  @override
  List<Object?> get props => [uri, platform];
}
