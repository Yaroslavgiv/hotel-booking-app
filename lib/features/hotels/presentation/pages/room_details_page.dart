import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobapp/l10n/app_localizations.dart';
import 'package:mobapp/features/hotels/application/cancel_booking_use_case.dart';
import 'package:mobapp/features/hotels/application/check_availability_use_case.dart';
import 'package:mobapp/features/hotels/application/create_booking_use_case.dart';
import 'package:mobapp/features/hotels/application/get_room_details_use_case.dart';
import 'package:mobapp/features/hotels/data/datasources/hotel_remote_data_source.dart';
import 'package:mobapp/features/hotels/data/repositories/hotel_repository_impl.dart';
import 'package:mobapp/features/hotels/domain/entities/booking.dart';
import 'package:mobapp/features/hotels/presentation/bloc/room_details/room_details_bloc.dart';
import 'package:mobapp/features/hotels/presentation/bloc/room_details/room_details_event.dart';
import 'package:mobapp/features/hotels/presentation/bloc/room_details/room_details_state.dart';

class RoomDetailsPage extends StatelessWidget {
  const RoomDetailsPage({required this.roomId, super.key});

  final String roomId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = HotelRepositoryImpl(HotelRemoteDataSource());
    final getRoomDetails = GetRoomDetailsUseCase(repository);
    final checkAvailability = CheckAvailabilityUseCase(repository);
    final createBooking = CreateBookingUseCase(repository);
    final cancelBooking = CancelBookingUseCase(repository);

    return BlocProvider<RoomDetailsBloc>(
      create: (BuildContext ctx) {
        final RoomDetailsBloc bloc = RoomDetailsBloc(
          getRoomDetails,
          checkAvailability,
          createBooking,
          cancelBooking,
        );

        try {
          final AuthState authState = ctx.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            bloc.add(
              GuestInfoChanged(
                name: authState.user.name,
                email: authState.user.email,
              ),
            );
          }
        } catch (e) {
          // AuthBloc может быть недоступен, это нормально
          // Пользователь сможет ввести данные вручную
        }

        bloc.add(LoadRoomDetailsRequested(roomId));
        return bloc;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (BuildContext context, AuthState authState) {
            // При изменении состояния авторизации обновляем информацию о пользователе
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
            final String currentRoomId = state.room?.id ?? roomId;

            return SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 320,
                      minHeight: 400,
                    ),
                    child: Column(
                      children: <Widget>[
                  _RoomHero(state: state, primary: primary, roomId: currentRoomId),
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
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                            if (state.guestName != null ||
                                state.guestEmail != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    if (state.guestName != null &&
                                        state.guestName!.isNotEmpty)
                                      Text(
                                        'Гость: ${state.guestName}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    if (state.guestEmail != null &&
                                        state.guestEmail!.isNotEmpty)
                                      Text(
                                        'Email: ${state.guestEmail}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
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
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            const _DateRangePicker(),
                            if (state.selectedStart != null &&
                                state.selectedEnd != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '${DateFormat.yMMMd().format(state.selectedStart!)} — '
                                  '${DateFormat.yMMMd().format(state.selectedEnd!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.grey[800]),
                                ),
                              ),
                            if (state.isAvailable != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
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
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      l10n.conflictingBookingsTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    for (final Booking b
                                        in state.conflictingBookings)
                                      Text(
                                        '- ${DateFormat.yMMMd().format(b.startDate.toLocal())} — '
                                        '${DateFormat.yMMMd().format(b.endDate.toLocal())}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                            if (state.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  state.errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      context
                                          .read<RoomDetailsBloc>()
                                          .add(const CheckAvailabilityRequested());
                                    },
                                    child: Text(l10n.buttonCheck),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _canBook(state)
                                        ? () {
                                            context
                                                .read<RoomDetailsBloc>()
                                                .add(
                                                  CreateBookingRequested(
                                                    guestName:
                                                        state.guestName ?? '',
                                                    guestEmail:
                                                        state.guestEmail ??
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
                                      padding: const EdgeInsets.symmetric(
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
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (BuildContext context) {
                                // Фильтруем брони - показываем только брони текущего пользователя
                                final String currentUserEmail = (state.guestEmail ?? '').trim();
                                final List<Booking> userBookings = state.bookings
                                    .where((Booking booking) {
                                      final String bookingEmail = (booking.guestEmail ?? '').trim();
                                      return bookingEmail.isNotEmpty &&
                                          currentUserEmail.isNotEmpty &&
                                          bookingEmail.toLowerCase() ==
                                              currentUserEmail.toLowerCase();
                                    })
                                    .toList();
                                
                                if (userBookings.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'У вас нет броней в этом номере',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey[600]),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                                
                                return ListView.builder(
                                  itemCount: userBookings.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final Booking booking =
                                        userBookings[index];
                                    final String bookingName = (booking.guestName ?? '').trim();
                                    final String bookingEmail = (booking.guestEmail ?? '').trim();
                                    
                                    // Проверяем владельца брони только по email
                                    final bool isCurrentUserBooking =
                                        booking.isActive &&
                                        bookingEmail.isNotEmpty &&
                                        currentUserEmail.isNotEmpty &&
                                        bookingEmail.toLowerCase() ==
                                            currentUserEmail.toLowerCase();
                                final String subtitleText =
                                    isCurrentUserBooking && bookingName.isNotEmpty
                                        ? bookingName
                                        : '';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(
                                      '${DateFormat.yMMMd().format(booking.startDate.toLocal())} — '
                                      '${DateFormat.yMMMd().format(booking.endDate.toLocal())}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: subtitleText.isNotEmpty
                                        ? Text(
                                            subtitleText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : null,
                                    trailing: booking.isActive && isCurrentUserBooking
                                        ? TextButton(
                                            onPressed: () async {
                                              // Подтверждение перед отменой
                                              final bool? confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (BuildContext context) => AlertDialog(
                                                  title: const Text('Отменить бронь?'),
                                                  content: const Text(
                                                    'Вы уверены, что хотите отменить эту бронь?',
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: const Text('Нет'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(true),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: Colors.red,
                                                      ),
                                                      child: const Text('Да, отменить'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true && context.mounted) {
                                                context
                                                    .read<RoomDetailsBloc>()
                                                    .add(
                                                      CancelBookingRequested(
                                                        booking.id,
                                                      ),
                                                    );
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const Icon(Icons.cancel_outlined, size: 18),
                                                const SizedBox(width: 4),
                                                Text(l10n.buttonCancel),
                                              ],
                                            ),
                                          )
                                        : null,
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

class _RoomHero extends StatelessWidget {
  const _RoomHero({
    required this.state,
    required this.primary,
    required this.roomId,
  });

  final RoomDetailsState state;
  final Color primary;
  final String roomId;

  @override
  Widget build(BuildContext context) {
    if (state.room == null) {
      return const SizedBox.shrink();
    }

    final room = state.room!;

    return Container(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Фоновое изображение
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Image.asset(
              'assets/images/hotel.jpg',
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[primary, primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
          ),
          // Затемнение для читаемости текста
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Номер ${room.number}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  room.type,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${room.price.toStringAsFixed(0)} ₽ / ночь',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                context.read<RoomDetailsBloc>().add(
                      LoadRoomDetailsRequested(roomId),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

bool _isValidEmail(String? email) {
  if (email == null || email.isEmpty) return false;
  final RegExp regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  return regex.hasMatch(email);
}

bool _canBook(RoomDetailsState state) {
  final bool hasDates =
      state.selectedStart != null && state.selectedEnd != null;
  final bool hasName = (state.guestName ?? '').isNotEmpty;
  final bool hasEmail = _isValidEmail(state.guestEmail);
  // Если по последней проверке номер явно помечен "занят", не даём бронировать.
  final bool notExplicitlyBusy = state.isAvailable != false;
  return hasDates && hasName && hasEmail && notExplicitlyBusy;
}

class _DateRangePicker extends StatelessWidget {
  const _DateRangePicker();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final DateTime now = DateTime.now();
              // Начало сегодняшнего дня - минимальная дата для выбора
              final DateTime todayStart = DateTime(now.year, now.month, now.day);
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: todayStart,
                lastDate: DateTime(now.year + 2),
                initialDateRange: null,
              );
              if (picked != null) {
                context.read<RoomDetailsBloc>().add(
                      DateRangeChanged(
                        picked.start,
                        picked.end,
                      ),
                    );
              }
            },
            child: Text(AppLocalizations.of(context)!.filtersDates),
          ),
        ),
      ],
    );
  }
}

