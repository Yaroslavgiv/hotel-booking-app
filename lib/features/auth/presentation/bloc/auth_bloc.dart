import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobapp/features/auth/domain/entities/user.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthUnauthenticated()) {
    on<AuthCredentialsSubmitted>(_onCredentialsSubmitted);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  void _onCredentialsSubmitted(
    AuthCredentialsSubmitted event,
    Emitter<AuthState> emit,
  ) {
    final User user = User(name: event.name, email: event.email);
    emit(AuthAuthenticated(user));
  }

  void _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthUnauthenticated());
  }
}

