import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hotel_booking_app/app/di/app_dependencies.dart';
import 'package:hotel_booking_app/features/auth/application/auth_use_cases.dart';
import 'package:hotel_booking_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hotel_booking_app/l10n/app_localizations.dart';
import 'package:hotel_booking_app/features/auth/presentation/pages/auth_page.dart';
import 'package:hotel_booking_app/features/auth/presentation/bloc/auth_event.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDependencies(
      child: BlocProvider<AuthBloc>(
        create: (BuildContext context) => AuthBloc(
          context.read<LoginUseCase>(),
          context.read<RegisterUseCase>(),
          context.read<RestoreSessionUseCase>(),
          context.read<LogoutUseCase>(),
        )..add(const AuthSessionRequested()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context).appTitle,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const <Locale>[Locale('ru'), Locale('en')],
          locale: const Locale('ru'),
          home: const AuthPage(),
        ),
      ),
    );
  }
}
