import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hotel_booking_app/core/errors/failure.dart';

class FailureMapper {
  const FailureMapper();

  Failure map(Object error) {
    if (error is Failure) {
      return error;
    }
    if (error is FormatException || error is TypeError) {
      return DataMappingFailure(
        'Сервер вернул данные в неожиданном формате.',
        cause: error,
      );
    }
    if (error is OperationException) {
      return _mapOperationException(error);
    }
    return UnknownFailure(
      'Произошла непредвиденная ошибка. Попробуйте ещё раз.',
      cause: error,
    );
  }

  Failure _mapOperationException(OperationException error) {
    if (error.linkException != null) {
      return NetworkFailure(
        'Не удалось подключиться к серверу. Проверьте соединение.',
        cause: error,
      );
    }

    final GraphQLError? graphQLError = error.graphqlErrors.isEmpty
        ? null
        : error.graphqlErrors.first;
    final String message = graphQLError?.message ??
        'Сервер не смог обработать запрос. Попробуйте ещё раз.';
    final String? code = graphQLError?.extensions?['code']?.toString();

    return switch (code) {
      'BAD_USER_INPUT' || 'VALIDATION_ERROR' =>
        ValidationFailure(message, cause: error),
      'NOT_FOUND' => NotFoundFailure(message, cause: error),
      _ => ServerFailure(message, cause: error),
    };
  }
}
