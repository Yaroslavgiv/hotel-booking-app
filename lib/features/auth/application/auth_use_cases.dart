import 'package:hotel_booking_app/features/auth/domain/entities/user.dart';
import 'package:hotel_booking_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;
  Future<User> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}

class RegisterUseCase {
  const RegisterUseCase(this._repository);
  final AuthRepository _repository;
  Future<User> call({
    required String name,
    required String email,
    required String password,
  }) => _repository.register(name: name, email: email, password: password);
}

class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);
  final AuthRepository _repository;
  Future<User?> call() => _repository.restoreSession();
}

class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final AuthRepository _repository;
  Future<void> call() => _repository.logout();
}
