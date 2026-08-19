import 'package:hotel_booking_app/core/errors/failure_mapper.dart';
import 'package:hotel_booking_app/core/security/token_storage.dart';
import 'package:hotel_booking_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hotel_booking_app/features/auth/domain/entities/auth_session.dart';
import 'package:hotel_booking_app/features/auth/domain/entities/user.dart';
import 'package:hotel_booking_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._remoteDataSource,
    this._tokenStorage, {
    FailureMapper failureMapper = const FailureMapper(),
  }) : _failureMapper = failureMapper;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;
  final FailureMapper _failureMapper;

  @override
  Future<User> login({required String email, required String password}) =>
      _authenticate(
        () => _remoteDataSource.login(email: email, password: password),
      );

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) => _authenticate(
    () => _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
    ),
  );

  @override
  Future<User?> restoreSession() async {
    final String? token = await _tokenStorage.read();
    if (token == null) {
      return null;
    }
    try {
      return await _remoteDataSource.fetchCurrentUser();
    } on Object catch (error) {
      await _tokenStorage.clear();
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> logout() => _tokenStorage.clear();

  Future<User> _authenticate(Future<AuthSession> Function() request) async {
    try {
      final AuthSession session = await request();
      await _tokenStorage.write(session.accessToken);
      return session.user;
    } on Object catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
