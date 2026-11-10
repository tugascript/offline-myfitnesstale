// Copyright (C) 2026 afonsobarracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

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
