abstract class Dto<T> {
  final int id;

  const Dto({
    required this.id,
  });

  factory Dto.fromModel(T model) {
    throw UnimplementedError();
  }

  Dto<T> copyWith({
    int? id,
  }) {
    throw UnimplementedError();
  }
}
