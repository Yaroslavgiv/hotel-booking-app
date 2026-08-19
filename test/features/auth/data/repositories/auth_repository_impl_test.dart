import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking_app/core/errors/failure.dart';
import 'package:hotel_booking_app/core/security/token_storage.dart';
import 'package:hotel_booking_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hotel_booking_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hotel_booking_app/features/auth/domain/entities/auth_session.dart';
import 'package:hotel_booking_app/features/auth/domain/entities/user.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late MockTokenStorage tokenStorage;
  late AuthRepositoryImpl repository;

  const user = User(
    id: 'user-1',
    name: 'Иван Иванов',
    email: 'ivan@example.com',
    role: 'USER',
  );
  const session = AuthSession(accessToken: 'access-token', user: user);

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    tokenStorage = MockTokenStorage();
    repository = AuthRepositoryImpl(remoteDataSource, tokenStorage);
  });

  test('login securely persists the token and returns the user', () async {
    when(
      () => remoteDataSource.login(
        email: 'ivan@example.com',
        password: 'password123',
      ),
    ).thenAnswer((_) async => session);
    when(() => tokenStorage.write('access-token')).thenAnswer((_) async {});

    final result = await repository.login(
      email: 'ivan@example.com',
      password: 'password123',
    );

    expect(result, user);
    verify(() => tokenStorage.write('access-token')).called(1);
  });

  test('restoreSession skips the API when there is no stored token', () async {
    when(() => tokenStorage.read()).thenAnswer((_) async => null);

    expect(await repository.restoreSession(), isNull);
    verifyNever(() => remoteDataSource.fetchCurrentUser());
  });

  test('restoreSession returns the current user for a stored token', () async {
    when(() => tokenStorage.read()).thenAnswer((_) async => 'access-token');
    when(
      () => remoteDataSource.fetchCurrentUser(),
    ).thenAnswer((_) async => user);

    expect(await repository.restoreSession(), user);
  });

  test('restoreSession clears a rejected session', () async {
    when(() => tokenStorage.read()).thenAnswer((_) async => 'expired-token');
    when(
      () => remoteDataSource.fetchCurrentUser(),
    ).thenThrow(Exception('session rejected'));
    when(() => tokenStorage.clear()).thenAnswer((_) async {});

    await expectLater(repository.restoreSession(), throwsA(isA<Failure>()));
    verify(() => tokenStorage.clear()).called(1);
  });

  test('logout clears the stored token', () async {
    when(() => tokenStorage.clear()).thenAnswer((_) async {});

    await repository.logout();

    verify(() => tokenStorage.clear()).called(1);
  });
}
