import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hotel_booking_app/core/errors/failure.dart';
import 'package:hotel_booking_app/core/errors/failure_mapper.dart';

void main() {
  const FailureMapper mapper = FailureMapper();

  group('FailureMapper', () {
    test('preserves an existing failure', () {
      const Failure failure = ValidationFailure('Некорректные даты');

      expect(mapper.map(failure), same(failure));
    });

    test('maps bad user input to a validation failure', () {
      final OperationException error = OperationException(
        graphqlErrors: <GraphQLError>[
          const GraphQLError(
            message: 'Дата выезда должна быть позже даты заезда',
            extensions: <String, dynamic>{'code': 'BAD_USER_INPUT'},
          ),
        ],
      );

      final Failure failure = mapper.map(error);

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Дата выезда должна быть позже даты заезда');
      expect(failure.cause, same(error));
    });

    test('maps a not found GraphQL error', () {
      final Failure failure = mapper.map(
        OperationException(
          graphqlErrors: <GraphQLError>[
            const GraphQLError(
              message: 'Номер не найден',
              extensions: <String, dynamic>{'code': 'NOT_FOUND'},
            ),
          ],
        ),
      );

      expect(failure, isA<NotFoundFailure>());
      expect(failure.message, 'Номер не найден');
    });

    test('maps malformed response data to a data mapping failure', () {
      final Failure failure = mapper.map(const FormatException('bad date'));

      expect(failure, isA<DataMappingFailure>());
    });

    test('maps an unknown exception without leaking implementation details', () {
      final Failure failure = mapper.map(StateError('internal detail'));

      expect(failure, isA<UnknownFailure>());
      expect(failure.message, isNot(contains('internal detail')));
    });
  });
}
