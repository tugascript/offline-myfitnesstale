enum SingleErrorTypes {
  notFound,
  invalidInput,
  operationFailure,
}

enum OperationErrorTypes {
  invalidInput,
  operationFailure,
}

class ServiceError<T> {
  final T type;
  final String description;

  const ServiceError({
    required this.type,
    required this.description,
  });
}
