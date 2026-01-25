import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'enums.dart';

abstract class JsonData {
  String toJson();

  factory JsonData.fromJson(String json) {
    throw UnimplementedError();
  }

  JsonData copyWith();
}

class VideoData extends Equatable implements JsonData {
  final VideoPlatform platform;
  final String uri;

  const VideoData({
    required this.platform,
    required this.uri,
  });

  @override
  String toJson() {
    return '{"platform":"${platform.value}","uri":"$uri"}';
  }

  @override
  factory VideoData.fromJson(String json) {
    final Map<String, String> map = jsonDecode(json);
    return VideoData(
      platform: VideoPlatform.fromValue(map['platform']!),
      uri: map['uri']!,
    );
  }

  @override
  VideoData copyWith({
    VideoPlatform? platform,
    String? uri,
  }) {
    return VideoData(
      platform: platform ?? this.platform,
      uri: uri ?? this.uri,
    );
  }

  @override
  List<Object?> get props => [platform, uri];
}

class PictureData extends Equatable implements JsonData {
  final PictureStorage storage;
  final String uri;

  const PictureData({
    required this.storage,
    required this.uri,
  });

  @override
  String toJson() {
    return '{"storage":"${storage.value}","uri":"$uri"}';
  }

  @override
  factory PictureData.fromJson(String json) {
    final Map<String, String> map = jsonDecode(json);
    return PictureData(
      storage: PictureStorage.fromValue(map['storage']!),
      uri: map['uri']!,
    );
  }

  @override
  PictureData copyWith({
    PictureStorage? storage,
    String? uri,
  }) {
    return PictureData(
      storage: storage ?? this.storage,
      uri: uri ?? this.uri,
    );
  }

  @override
  List<Object?> get props => [storage, uri];
}
