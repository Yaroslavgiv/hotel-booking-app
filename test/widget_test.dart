import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking_app/features/auth/presentation/pages/auth_page.dart';
import 'package:hotel_booking_app/main.dart';

void main() {
  testWidgets('renders the hotel booking authentication flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
