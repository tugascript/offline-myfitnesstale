import 'package:equatable/equatable.dart';

class ErrorState extends Equatable {
  final String type;
  final String description;

  const ErrorState({
    required this.type,
    required this.description,
  });

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
    return const PaginationState(
      limit: 10,
      offset: 0,
      total: 0,
    );
  }

  PaginationState copyWith({
    int? limit,
    int? offset,
    int? total,
  }) {
    return PaginationState(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
        limit,
        offset,
        total,
      ];
}
