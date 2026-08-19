import 'package:equatable/equatable.dart';
import 'package:hotel_booking_app/features/auth/domain/entities/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => <Object?>[];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthSessionLoading extends AuthState {
  const AuthSessionLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
  @override
  List<Object?> get props => <Object?>[user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;
  @override
  List<Object?> get props => <Object?>[message];
}
