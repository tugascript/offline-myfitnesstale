class PaginatedDto<T, U> {
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
