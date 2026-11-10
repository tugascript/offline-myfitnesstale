/// Domain DTO mapped from a SQLite model [T].
///
/// Concrete DTOs should also declare:
/// - `factory Foo.fromModel(T model, {...})`
/// - `Foo copyWith({...})` returning the concrete type
abstract interface class Dto<T> {
  final int id;

  const Dto({required this.id});

  Dto<T> copyWith();
}
