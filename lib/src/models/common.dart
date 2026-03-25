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

class TargetMuscles extends Equatable implements JsonData {
  final Set<Muscle> primary;
  final Set<Muscle> secondary;

  const TargetMuscles({
    required this.primary,
    required this.secondary,
  });

  Map<String, List<String>> toMap() {
    return {
      'primary': primary.map((m) => m.value).toList(),
      'secondary': secondary.map((m) => m.value).toList(),
    };
  }

  factory TargetMuscles.fromJson(String json) {
    final Map<String, dynamic> decodedJson = jsonDecode(json);
    return TargetMuscles.fromMap({
      'primary': List<String>.from(decodedJson['primary'] ?? []),
      'secondary': List<String>.from(decodedJson['secondary'] ?? []),
    });
  }

  factory TargetMuscles.fromMap(Map<String, List<String>> map) {
    return TargetMuscles(
      primary:
          map['primary']?.map((m) => Muscle.fromValue(m)).toSet() ?? <Muscle>{},
      secondary: map['secondary']?.map((m) => Muscle.fromValue(m)).toSet() ??
          <Muscle>{},
    );
  }

  @override
  TargetMuscles copyWith({
    Set<Muscle>? primary,
    Set<Muscle>? secondary,
  }) {
    return TargetMuscles(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
    );
  }

  TargetMuscles addOther(TargetMuscles other) {
    final Set<Muscle> primary = this.primary.union(other.primary);
    final Set<Muscle> secondary = this.secondary.union(other.secondary);
    secondary.removeAll(primary);

    return TargetMuscles(
      primary: primary,
      secondary: secondary,
    );
  }

  @override
  String toJson() {
    return jsonEncode(toMap());
  }

  @override
  List<Object?> get props => [primary, secondary];
}
