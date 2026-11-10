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

final class PaginatedDto<T, U> {
  final List<T> data;
  final int total;
  final int limit;
  final int offset;

  const PaginatedDto({
    required this.data,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory PaginatedDto.mapData({
    required List<U> data,
    required T Function(U) mapper,
    required int total,
    required int limit,
    required int offset,
  }) {
    return PaginatedDto(
      data: data.map(mapper).toList(),
      total: total,
      limit: limit,
      offset: offset,
    );
  }

  PaginatedDto<T, U> copyWith({
    List<T>? data,
    int? total,
    int? limit,
    int? offset,
  }) {
    return PaginatedDto<T, U>(
      data: data ?? this.data,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}
