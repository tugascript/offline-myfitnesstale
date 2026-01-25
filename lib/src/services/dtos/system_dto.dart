import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/system_model.dart';
import 'dto.dart';

class SystemDto extends Equatable implements Dto<System> {
  @override
  final int id;
  final Units units;
  final ThemeType theme;
  final SetUpStatus initialSetup;

  const SystemDto({
    required this.id,
    required this.units,
    required this.theme,
    required this.initialSetup,
  });

  @override
  factory SystemDto.fromModel(System model) {
    return SystemDto(
      id: model.id!,
      units: model.units,
      theme: model.theme,
      initialSetup: model.initialSetup,
    );
  }

  @override
  SystemDto copyWith({
    int? id,
    Units? units,
    ThemeType? theme,
    SetUpStatus? initialSetup,
  }) {
    return SystemDto(
      id: id ?? this.id,
      units: units ?? this.units,
      theme: theme ?? this.theme,
      initialSetup: initialSetup ?? this.initialSetup,
    );
  }

  @override
  List<Object?> get props => [id, units, theme, initialSetup];
}
