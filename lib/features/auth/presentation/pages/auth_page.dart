import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_booking_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hotel_booking_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:hotel_booking_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:hotel_booking_app/features/hotels/presentation/pages/hotels_page.dart';
import 'package:hotel_booking_app/features/hotels/presentation/pages/windows_overview_page.dart';
import 'package:hotel_booking_app/l10n/app_localizations.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRegistration = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    if (_isRegistration) {
      context.read<AuthBloc>().add(
        AuthRegistrationSubmitted(name: name, email: email, password: password),
      );
    } else {
      context.read<AuthBloc>().add(
        AuthLoginSubmitted(email: email, password: password),
      );
    }
  }

  void _openApplication() {
    final Widget destination = defaultTargetPlatform == TargetPlatform.windows
        ? const WindowsOverviewPage()
        : const HotelsPage();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<Widget>(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color primary = Theme.of(context).colorScheme.primary;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthAuthenticated) {
          _openApplication();
        }
      },
      builder: (BuildContext context, AuthState state) {
        final bool loading = state is AuthLoading;
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.hotel, color: primary, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _isRegistration ? 'Создать аккаунт' : l10n.authTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      if (_isRegistration) ...<Widget>[
                        TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: _decoration(
                            l10n.authNameLabel,
                            Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration(
                          l10n.authEmailLabel,
                          Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onSubmitted: loading ? null : (_) => _submit(),
                        decoration: _decoration('Пароль', Icons.lock_outline)
                            .copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                      ),
                      if (state case AuthFailure(
                        :final String message,
                      )) ...<Widget>[
                        const SizedBox(height: 14),
                        Text(
                          message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
                          child: loading
                              ? const SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isRegistration
                                      ? 'Зарегистрироваться'
                                      : 'Войти',
                                ),
                        ),
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () => setState(
                                () => _isRegistration = !_isRegistration,
                              ),
                        child: Text(
                          _isRegistration
                              ? 'Уже есть аккаунт? Войти'
                              : 'Нет аккаунта? Зарегистрироваться',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
