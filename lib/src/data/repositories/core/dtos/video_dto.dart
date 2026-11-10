import 'package:equatable/equatable.dart';

import 'package:myfitnesstale/src/data/utils/json_data.dart';
import 'package:myfitnesstale/src/data/utils/enums.dart';

class VideoDto extends Equatable {
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
