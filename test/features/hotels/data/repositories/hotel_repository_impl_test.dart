import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hotel_booking_app/core/errors/failure.dart';
import 'package:hotel_booking_app/features/hotels/data/datasources/hotel_remote_data_source.dart';
import 'package:hotel_booking_app/features/hotels/data/repositories/hotel_repository_impl.dart';
import 'package:hotel_booking_app/features/hotels/domain/entities/hotel.dart';
import 'package:mocktail/mocktail.dart';

class MockHotelRemoteDataSource extends Mock implements HotelRemoteDataSource {}

void main() {
  late MockHotelRemoteDataSource remote;
  late HotelRepositoryImpl repository;

  setUp(() {
    remote = MockHotelRemoteDataSource();
    repository = HotelRepositoryImpl(remote);
  });

  group('HotelRepositoryImpl', () {
    test('returns hotels from the remote data source', () async {
      const List<Hotel> hotels = <Hotel>[
        Hotel(id: 'hotel-1', name: 'Aurora', address: 'London'),
      ];
      when(() => remote.fetchHotels()).thenAnswer((_) async => hotels);

      final List<Hotel> result = await repository.getHotels();

      expect(result, same(hotels));
      verify(() => remote.fetchHotels()).called(1);
    });

    test(
      'translates GraphQL errors before they leave the repository',
      () async {
        when(() => remote.fetchHotels()).thenThrow(
          OperationException(
            graphqlErrors: <GraphQLError>[
              const GraphQLError(
                message: 'Параметры запроса некорректны',
                extensions: <String, dynamic>{'code': 'BAD_USER_INPUT'},
              ),
            ],
          ),
        );

        await expectLater(
          repository.getHotels(),
          throwsA(
            isA<ValidationFailure>().having(
              (ValidationFailure failure) => failure.message,
              'message',
              'Параметры запроса некорректны',
            ),
          ),
        );
      },
    );

    test('does not leak unexpected infrastructure errors', () async {
      when(() => remote.fetchHotels()).thenThrow(StateError('database host'));

      await expectLater(repository.getHotels(), throwsA(isA<UnknownFailure>()));
    });
  });
}
