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
