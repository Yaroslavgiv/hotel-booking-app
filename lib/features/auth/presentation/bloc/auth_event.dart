import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => <Object?>[];
}

final class AuthSessionRequested extends AuthEvent {
  const AuthSessionRequested();
}

final class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object?> get props => <Object?>[email, password];
}

final class AuthRegistrationSubmitted extends AuthEvent {
  const AuthRegistrationSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
  @override
  List<Object?> get props => <Object?>[name, email, password];
}

final class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}
