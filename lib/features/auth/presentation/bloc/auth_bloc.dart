import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_booking_app/core/errors/failure_message.dart';
import 'package:hotel_booking_app/features/auth/application/auth_use_cases.dart';
import 'package:hotel_booking_app/features/auth/domain/entities/user.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._login, this._register, this._restoreSession, this._logout)
    : super(const AuthInitial()) {
    on<AuthSessionRequested>(_onSessionRequested);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegistrationSubmitted>(_onRegistrationSubmitted);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final RestoreSessionUseCase _restoreSession;
  final LogoutUseCase _logout;

  Future<void> _onSessionRequested(
    AuthSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final User? user = await _restoreSession();
      emit(
        user == null ? const AuthUnauthenticated() : AuthAuthenticated(user),
      );
    } on Object catch (error) {
      emit(AuthFailure(failureMessage(error)));
    }
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) => _authenticate(
    () => _login(email: event.email, password: event.password),
    emit,
  );

  Future<void> _onRegistrationSubmitted(
    AuthRegistrationSubmitted event,
    Emitter<AuthState> emit,
  ) => _authenticate(
    () => _register(
      name: event.name,
      email: event.email,
      password: event.password,
    ),
    emit,
  );

  Future<void> _authenticate(
    Future<User> Function() request,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      emit(AuthAuthenticated(await request()));
    } on Object catch (error) {
      emit(AuthFailure(failureMessage(error)));
    }
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(const AuthUnauthenticated());
  }
}
