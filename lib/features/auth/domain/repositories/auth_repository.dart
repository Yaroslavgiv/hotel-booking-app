import 'package:hotel_booking_app/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String name,
    required String email,
    required String password,
  });
  Future<User?> restoreSession();
  Future<void> logout();
}
