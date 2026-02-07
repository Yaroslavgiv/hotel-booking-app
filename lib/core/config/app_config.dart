import 'dart:io';

class AppConfig {
  AppConfig._();

  /// URL GraphQL-сервера из Backend (`npm run dev`).
  /// На Android-эмуляторе localhost — это сам эмулятор, поэтому используем 10.0.2.2.
  /// Порт бекенда: 4001.
  static String get graphQLEndpoint {
    if (Platform.isAndroid) {
      // Android Emulator (AVD) → обращаемся к хосту по 10.0.2.2
      return 'http://10.0.2.2:4001/graphql';
    }
    // Для iOS-симулятора / Windows desktop можно использовать localhost или свой IP.
    return 'http://localhost:4001/graphql';
  }
}

