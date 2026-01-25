Ok<T, E> ok<T, E>(T value) => Ok<T, E>(value);

Err<T, E> err<T, E>(E error) => Err<T, E>(error);

abstract interface class Result<T, E> {
  bool isOk() => throw UnimplementedError();

  bool isErr() => throw UnimplementedError();

  T get value => throw UnimplementedError();

  E get error => throw UnimplementedError();
}

class Ok<T, E> implements Result<T, E> {
  final T _value;

  const Ok(T value) : _value = value;

  @override
  bool isOk() => true;

  @override
  bool isErr() => false;

  @override
  T get value => _value;

  @override
  E get error => throw Exception("Cannot get error from Ok");
}

class Err<T, E> implements Result<T, E> {
  final E _error;

  const Err(E error) : _error = error;

  @override
  bool isOk() => false;

  @override
  bool isErr() => true;

  @override
  E get error => _error;

  @override
  T get value => throw Exception("Cannot get value from Err");
}
