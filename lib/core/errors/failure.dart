sealed class Failure implements Exception {
  const Failure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause});
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.cause});
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.cause});
}

final class DataMappingFailure extends Failure {
  const DataMappingFailure(super.message, {super.cause});
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause});
}
