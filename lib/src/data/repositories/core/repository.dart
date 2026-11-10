/// Base type for feature repositories.
///
/// Concrete repositories should expose a factory that wires default DAOs:
///
/// ```dart
/// factory FooRepository.create([DatabaseHelper? databaseHelper]);
/// ```
///
/// Prefer injecting DAOs via the generative constructor in tests.
abstract interface class Repository {}
