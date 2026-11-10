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

mixin ErrorTypes {
  String get name;
}

enum SingleErrorTypes implements ErrorTypes {
  notFound("Not Found"),
  invalidInput("Invalid Input"),
  operationFailure("Operation Failure");

  @override
  final String name;

  const SingleErrorTypes(this.name);
}

enum OperationErrorTypes implements ErrorTypes {
  invalidInput("Invalid Input"),
  operationFailure("Operation Failure");

  @override
  final String name;

  const OperationErrorTypes(this.name);
}

final class ServiceError<T extends ErrorTypes> {
  final T type;
  final String description;

  const ServiceError({required this.type, required this.description});

  @override
  String toString() => 'Error ${type.name}: $description';
}
