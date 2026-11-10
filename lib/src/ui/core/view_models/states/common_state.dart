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

class ErrorState extends Equatable {
  final String type;
  final String description;

  const ErrorState({required this.type, required this.description});

  @override
  List<Object?> get props => [type, description];
}

class PaginationState extends Equatable {
  final int limit;
  final int offset;
  final int total;

  const PaginationState({
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory PaginationState.initial() {
    return const PaginationState(limit: 10, offset: 0, total: 0);
  }

  PaginationState copyWith({int? limit, int? offset, int? total}) {
    return PaginationState(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [limit, offset, total];
}
