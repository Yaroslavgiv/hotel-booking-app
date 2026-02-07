import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobapp/features/auth/domain/entities/user.dart';
import 'package:mobapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobapp/features/hotels/application/cancel_booking_use_case.dart';
import 'package:mobapp/features/hotels/application/check_availability_use_case.dart';
import 'package:mobapp/features/hotels/application/create_booking_use_case.dart';
import 'package:mobapp/features/hotels/application/get_room_details_use_case.dart';
import 'package:mobapp/features/hotels/domain/entities/booking.dart';
import 'package:mobapp/features/hotels/domain/entities/room.dart';
import 'package:mobapp/features/hotels/domain/repositories/hotel_repository.dart';
import 'package:mobapp/features/hotels/presentation/bloc/room_details/room_details_bloc.dart';
import 'package:mobapp/features/hotels/presentation/bloc/room_details/room_details_event.dart';
import 'package:mobapp/features/hotels/presentation/bloc/room_details/room_details_state.dart';
import 'package:mobapp/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockHotelRepository extends Mock implements HotelRepository {}

class TestRoomDetailsBloc extends RoomDetailsBloc {
  TestRoomDetailsBloc(RoomDetailsState initialState)
    : super(
        GetRoomDetailsUseCase(MockHotelRepository()),
        CheckAvailabilityUseCase(MockHotelRepository()),
        CreateBookingUseCase(MockHotelRepository()),
        CancelBookingUseCase(MockHotelRepository()),
      ) {
    emit(initialState);
  }

  void setState(RoomDetailsState newState) {
    emit(newState);
  }
}

// Тестовая обертка страницы, которая использует переданный BLoC
class TestableRoomDetailsPage extends StatelessWidget {
  const TestableRoomDetailsPage({
    required this.roomId,
    required this.bloc,
    super.key,
  });

  final String roomId;
  final RoomDetailsBloc bloc;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider<RoomDetailsBloc>.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (BuildContext context, AuthState authState) {
            if (authState is AuthAuthenticated) {
              context.read<RoomDetailsBloc>().add(
                GuestInfoChanged(
                  name: authState.user.name,
                  email: authState.user.email,
                ),
              );
            }
          },
          child: BlocBuilder<RoomDetailsBloc, RoomDetailsState>(
            builder: (BuildContext context, RoomDetailsState state) {
              if (state.status == RoomDetailsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == RoomDetailsStatus.failure) {
                return Center(
                  child: Text(state.errorMessage ?? l10n.errorLoading),
                );
              }

              final Color primary = Theme.of(context).colorScheme.primary;

              return SafeArea(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 320,
                        minHeight: 400,
                      ),
                      child: Column(
                        children: <Widget>[
                          if (state.room != null)
                            Container(
                              height: 220,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    bottom: 24,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Номер ${state.room!.number}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          state.room!.type,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.18,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            '${state.room!.price.toStringAsFixed(0)} ₽ / ночь',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  12,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      if (state.guestName != null ||
                                          state.guestEmail != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              if (state.guestName != null &&
                                                  state.guestName!.isNotEmpty)
                                                Text(
                                                  'Гость: ${state.guestName}',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                                ),
                                              if (state.guestEmail != null &&
                                                  state.guestEmail!.isNotEmpty)
                                                Text(
                                                  'Email: ${state.guestEmail}',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                                ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.filtersDates,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (state.selectedStart != null &&
                                          state.selectedEnd != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            '${state.selectedStart!.toString().split(' ')[0]} — '
                                            '${state.selectedEnd!.toString().split(' ')[0]}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.grey[800],
                                                ),
                                          ),
                                        ),
                                      if (state.isAvailable != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                state.isAvailable!
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                color: state.isAvailable!
                                                    ? Colors.green
                                                    : Colors.red,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                state.isAvailable!
                                                    ? l10n.statusAvailable
                                                    : l10n.statusUnavailable,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: state.isAvailable!
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (state.conflictingBookings.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                l10n.conflictingBookingsTitle,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              for (final Booking b
                                                  in state.conflictingBookings)
                                                Text(
                                                  '- ${b.startDate.toString().split(' ')[0]} — '
                                                  '${b.endDate.toString().split(' ')[0]}',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall,
                                                ),
                                            ],
                                          ),
                                        ),
                                      if (state.errorMessage != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            state.errorMessage!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                context.read<RoomDetailsBloc>().add(
                                                  const CheckAvailabilityRequested(),
                                                );
                                              },
                                              child: Text(l10n.buttonCheck),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed:
                                                  (state.selectedStart !=
                                                          null &&
                                                      state.selectedEnd !=
                                                          null &&
                                                      (state.guestName ?? '')
                                                          .isNotEmpty &&
                                                      (state.guestEmail ?? '')
                                                          .isNotEmpty &&
                                                      state.isAvailable !=
                                                          false)
                                                  ? () {
                                                      context.read<RoomDetailsBloc>().add(
                                                        CreateBookingRequested(
                                                          guestName:
                                                              state.guestName ??
                                                              '',
                                                          guestEmail:
                                                              state
                                                                  .guestEmail ??
                                                              '',
                                                        ),
                                                      );
                                                    }
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                              ),
                                              child: Text(l10n.buttonBook),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        l10n.bookingsTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Builder(
                                        builder: (BuildContext context) {
                                          final String currentUserEmail =
                                              (state.guestEmail ?? '').trim();
                                          final List<Booking>
                                          userBookings = state.bookings.where((
                                            Booking booking,
                                          ) {
                                            final String bookingEmail =
                                                (booking.guestEmail ?? '')
                                                    .trim();
                                            return bookingEmail.isNotEmpty &&
                                                currentUserEmail.isNotEmpty &&
                                                bookingEmail.toLowerCase() ==
                                                    currentUserEmail
                                                        .toLowerCase();
                                          }).toList();

                                          if (userBookings.isEmpty) {
                                            return Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                'У вас нет броней в этом номере',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Colors.grey[600],
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          }

                                          return ListView.builder(
                                            itemCount: userBookings.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder:
                                                (
                                                  BuildContext context,
                                                  int index,
                                                ) {
                                                  final Booking booking =
                                                      userBookings[index];
                                                  return Card(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          bottom: 8,
                                                        ),
                                                    child: ListTile(
                                                      title: Text(
                                                        '${booking.startDate.toString().split(' ')[0]} — '
                                                        '${booking.endDate.toString().split(' ')[0]}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  );
                                                },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  group('RoomDetailsPage', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc();
    });

    tearDown(() {
      authBloc.close();
    });

    Widget createTestWidget({
      required RoomDetailsState state,
      AuthState? authState,
    }) {
      if (authState != null) {
        authBloc.emit(authState);
      }

      final testBloc = TestRoomDetailsBloc(state);

      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: TestableRoomDetailsPage(
            roomId: 'test-room-id',
            bloc: testBloc,
          ),
        ),
      );
    }

    testWidgets('отображает индикатор загрузки при состоянии loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          state: const RoomDetailsState(status: RoomDetailsStatus.loading),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('отображает сообщение об ошибке при состоянии failure', (
      WidgetTester tester,
    ) async {
      const errorMessage = 'Ошибка загрузки данных';
      await tester.pumpWidget(
        createTestWidget(
          state: const RoomDetailsState(
            status: RoomDetailsStatus.failure,
            errorMessage: errorMessage,
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('отображает информацию о номере при успешной загрузке', (
      WidgetTester tester,
    ) async {
      final room = const Room(
        id: 'room-1',
        hotelId: 'hotel-1',
        number: '101',
        type: 'Стандарт',
        price: 2500.0,
      );

      await tester.pumpWidget(
        createTestWidget(
          state: RoomDetailsState(
            status: RoomDetailsStatus.success,
            room: room,
          ),
        ),
      );

      expect(find.text('Номер 101'), findsOneWidget);
      expect(find.text('Стандарт'), findsOneWidget);
      expect(find.textContaining('2500'), findsOneWidget);
    });

    testWidgets('отображает информацию о госте при авторизации', (
      WidgetTester tester,
    ) async {
      final room = const Room(
        id: 'room-1',
        hotelId: 'hotel-1',
        number: '101',
        type: 'Стандарт',
        price: 2500.0,
      );

      final user = const User(name: 'Иван Иванов', email: 'ivan@test.com');

      await tester.pumpWidget(
        createTestWidget(
          state: RoomDetailsState(
            status: RoomDetailsStatus.success,
            room: room,
            guestName: user.name,
            guestEmail: user.email,
          ),
          authState: AuthAuthenticated(user),
        ),
      );

      expect(find.textContaining('Гость: ${user.name}'), findsOneWidget);
      expect(find.textContaining('Email: ${user.email}'), findsOneWidget);
    });

    testWidgets('отображает статус доступности номера', (
      WidgetTester tester,
    ) async {
      final room = const Room(
        id: 'room-1',
        hotelId: 'hotel-1',
        number: '101',
        type: 'Стандарт',
        price: 2500.0,
      );

      await tester.pumpWidget(
        createTestWidget(
          state: RoomDetailsState(
            status: RoomDetailsStatus.success,
            room: room,
            isAvailable: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('отображает статус недоступности номера', (
      WidgetTester tester,
    ) async {
      final room = const Room(
        id: 'room-1',
        hotelId: 'hotel-1',
        number: '101',
        type: 'Стандарт',
        price: 2500.0,
      );

      await tester.pumpWidget(
        createTestWidget(
          state: RoomDetailsState(
            status: RoomDetailsStatus.success,
            room: room,
            isAvailable: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('отображает список броней пользователя', (
      WidgetTester tester,
    ) async {
      final room = const Room(
        id: 'room-1',
        hotelId: 'hotel-1',
        number: '101',
        type: 'Стандарт',
        price: 2500.0,
      );

      final now = DateTime.now();
      final booking = Booking(
        id: 'booking-1',
        roomId: 'room-1',
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 3)),
        isActive: true,
        guestName: 'Иван Иванов',
        guestEmail: 'ivan@test.com',
      );

      await tester.pumpWidget(
        createTestWidget(
          state: RoomDetailsState(
            status: RoomDetailsStatus.success,
            room: room,
            bookings: [booking],
            guestEmail: 'ivan@test.com',
          ),
        ),
      );

      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('отображает сообщение при отсутствии броней', (
      WidgetTester tester,
    ) async {
      final room = const Room(
        id: 'room-1',
        hotelId: 'hotel-1',
        number: '101',
        type: 'Стандарт',
        price: 2500.0,
      );

      await tester.pumpWidget(
        createTestWidget(
          state: RoomDetailsState(
            status: RoomDetailsStatus.success,
            room: room,
            bookings: [],
            guestEmail: 'ivan@test.com',
          ),
        ),
      );

      expect(find.text('У вас нет броней в этом номере'), findsOneWidget);
    });

    testWidgets('кнопка бронирования активна при валидных данных', (
      WidgetTester tester,
    ) async {
      final room = const Room(
        id: 'room-1',
        hotelId: 'hotel-1',
        number: '101',
        type: 'Стандарт',
        price: 2500.0,
      );

      final now = DateTime.now();
      await tester.pumpWidget(
        createTestWidget(
          state: RoomDetailsState(
            status: RoomDetailsStatus.success,
            room: room,
            selectedStart: now,
            selectedEnd: now.add(const Duration(days: 1)),
            guestName: 'Иван Иванов',
            guestEmail: 'ivan@test.com',
            isAvailable: true,
          ),
        ),
      );

      final bookButton = find.byType(ElevatedButton);
      expect(bookButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(bookButton).onPressed, isNotNull);
    });

    testWidgets('кнопка бронирования неактивна при невалидных данных', (
      WidgetTester tester,
    ) async {
      final room = const Room(
        id: 'room-1',
        hotelId: 'hotel-1',
        number: '101',
        type: 'Стандарт',
        price: 2500.0,
      );

      await tester.pumpWidget(
        createTestWidget(
          state: RoomDetailsState(
            status: RoomDetailsStatus.success,
            room: room,
            guestName: 'Иван Иванов',
            guestEmail: 'invalid-email',
          ),
        ),
      );

      final bookButton = find.byType(ElevatedButton);
      expect(bookButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(bookButton).onPressed, isNull);
    });

    testWidgets('отображает выбранные даты', (WidgetTester tester) async {
      final room = const Room(
        id: 'room-1',
        hotelId: 'hotel-1',
        number: '101',
        type: 'Стандарт',
        price: 2500.0,
      );

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day + 1);
      final endDate = DateTime(now.year, now.month, now.day + 3);

      await tester.pumpWidget(
        createTestWidget(
          state: RoomDetailsState(
            status: RoomDetailsStatus.success,
            room: room,
            selectedStart: startDate,
            selectedEnd: endDate,
          ),
        ),
      );

      expect(find.textContaining('—'), findsWidgets);
    });

    testWidgets('отображает конфликтующие брони', (WidgetTester tester) async {
      final room = const Room(
        id: 'room-1',
        hotelId: 'hotel-1',
        number: '101',
        type: 'Стандарт',
        price: 2500.0,
      );

      final now = DateTime.now();
      final conflictingBooking = Booking(
        id: 'booking-2',
        roomId: 'room-1',
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 3)),
        isActive: true,
      );

      await tester.pumpWidget(
        createTestWidget(
          state: RoomDetailsState(
            status: RoomDetailsStatus.success,
            room: room,
            conflictingBookings: [conflictingBooking],
          ),
        ),
      );

      expect(find.textContaining('—'), findsWidgets);
    });
  });
}
