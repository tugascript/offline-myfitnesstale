// Copyright (C) 2026 Afonso Barracha
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

import '../../../models/sqlite/system_model.dart';
import '../../../utils/enums.dart';
import '../../core/dtos/dto.dart';

final class SystemDto extends Equatable implements ModelDto<System> {
  @override
  final int id;
  final Units units;
  final ThemeType theme;
  final SetUpStatus initialSetup;
  final bool notificationsOn;

  const SystemDto({
    required this.id,
    required this.units,
    required this.theme,
    required this.initialSetup,
    required this.notificationsOn,
  });

  factory SystemDto.fromModel(System model) {
    return SystemDto(
      id: model.id!,
      units: model.units,
      theme: model.theme,
      initialSetup: model.initialSetup,
      notificationsOn: model.notificationsOn,
    );
  }

  @override
  SystemDto copyWith({
    int? id,
    Units? units,
    ThemeType? theme,
    SetUpStatus? initialSetup,
    bool? notificationsOn,
  }) {
    return SystemDto(
      id: id ?? this.id,
      units: units ?? this.units,
      theme: theme ?? this.theme,
      initialSetup: initialSetup ?? this.initialSetup,
      notificationsOn: notificationsOn ?? this.notificationsOn,
    );
  }

  @override
  List<Object?> get props => [id, units, theme, initialSetup, notificationsOn];
}
