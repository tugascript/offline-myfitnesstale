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

/// Domain DTO mapped from a SQLite model [T].
///
/// Concrete DTOs should also declare:
/// - `factory Foo.fromModel(T model, {...})`
/// - `Foo copyWith({...})` returning the concrete type
abstract interface class ModelDto<T> extends Equatable {
  final int id;

  const ModelDto({required this.id});

  ModelDto<T> copyWith();
}

/// Normal DTO
abstract interface class Dto extends Equatable {
  Dto copyWith();
}
