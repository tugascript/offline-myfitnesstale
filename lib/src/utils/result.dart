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
