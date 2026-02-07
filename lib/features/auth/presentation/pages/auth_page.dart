import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobapp/features/hotels/presentation/pages/hotels_page.dart';
import 'package:mobapp/features/hotels/presentation/pages/windows_overview_page.dart';
import 'package:mobapp/l10n/app_localizations.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(email);
  }

  void _submit() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty || !_isValidEmail(email)) {
      setState(() {
        _error = AppLocalizations.of(context)!.errorInvalidAuth;
      });
      return;
    }

    context.read<AuthBloc>().add(
          AuthCredentialsSubmitted(name: name, email: email),
        );

    final bool isWindows = defaultTargetPlatform == TargetPlatform.windows;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<Widget>(
        builder: (_) => isWindows
            ? const WindowsOverviewPage()
            : const HotelsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Градиентный header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[primary, primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.appTitle,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: onPrimary.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.authTitle,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: onPrimary.withOpacity(0.15),
                        child: Icon(
                          Icons.person_outline,
                          color: onPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Белый контейнер с формой - по центру
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    padding: const EdgeInsets.all(24),
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                      Text(
                        'Введите ваши данные',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Поле имени
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.authNameLabel,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Поле email
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: l10n.authEmailLabel,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      // Сообщение об ошибке
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_error != null) const SizedBox(height: 20),
                      // Кнопка входа
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.authContinue,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

