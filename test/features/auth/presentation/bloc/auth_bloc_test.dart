import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking_app/features/auth/application/auth_use_cases.dart';
import 'package:hotel_booking_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hotel_booking_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:hotel_booking_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockRestoreSessionUseCase extends Mock implements RestoreSessionUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late MockLogoutUseCase logoutUseCase;
  late AuthBloc authBloc;

  setUp(() {
    logoutUseCase = MockLogoutUseCase();
    authBloc = AuthBloc(
      MockLoginUseCase(),
      MockRegisterUseCase(),
      MockRestoreSessionUseCase(),
      logoutUseCase,
    );
  });

  tearDown(() => authBloc.close());

  test('logout clears the session before emitting unauthenticated', () async {
    when(() => logoutUseCase()).thenAnswer((_) async {});

    authBloc.add(const AuthLoggedOut());

    await expectLater(
      authBloc.stream,
      emitsInOrder(<Object>[isA<AuthUnauthenticated>()]),
    );
    verify(() => logoutUseCase()).called(1);
  });
}
