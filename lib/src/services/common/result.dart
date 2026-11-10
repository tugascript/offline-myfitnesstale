abstract interface class Result<T, E> {
  bool isOk() => throw UnimplementedError();

  bool isErr() => throw UnimplementedError();

  T get value => throw UnimplementedError();

  E get error => throw UnimplementedError();
}

final class _Ok<T, E> implements Result<T, E> {
  final T _value;

  const _Ok(T value) : _value = value;

  @override
  bool isOk() => true;

  @override
  bool isErr() => false;

  @override
  T get value => _value;

  @override
  E get error => throw Exception("Cannot get error from Ok");
}

final class _Err<T, E> implements Result<T, E> {
  final E _error;

  const _Err(E error) : _error = error;

  @override
  bool isOk() => false;

  @override
  bool isErr() => true;

  @override
  E get error => _error;

  @override
  T get value => throw Exception("Cannot get value from Err");
}

Result<T, E> ok<T, E>(T value) => _Ok<T, E>(value);

Result<T, E> err<T, E>(E error) => _Err<T, E>(error);
