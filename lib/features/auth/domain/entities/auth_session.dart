import 'package:equatable/equatable.dart';
import 'package:hotel_booking_app/features/auth/domain/entities/user.dart';

class AuthSession extends Equatable {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final User user;

  @override
  List<Object?> get props => <Object?>[accessToken, user];
}
