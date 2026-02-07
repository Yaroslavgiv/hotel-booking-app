import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCredentialsSubmitted extends AuthEvent {
  const AuthCredentialsSubmitted({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  List<Object?> get props => [name, email];
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}

