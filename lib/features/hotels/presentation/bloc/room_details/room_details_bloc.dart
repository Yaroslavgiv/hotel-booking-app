import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobapp/features/hotels/application/cancel_booking_use_case.dart';
import 'package:mobapp/features/hotels/application/check_availability_use_case.dart';
import 'package:mobapp/features/hotels/application/create_booking_use_case.dart';
import 'package:mobapp/features/hotels/application/get_room_details_use_case.dart';
import 'package:mobapp/features/hotels/domain/entities/booking.dart';

import 'room_details_event.dart';
import 'room_details_state.dart';

class RoomDetailsBloc extends Bloc<RoomDetailsEvent, RoomDetailsState> {
  RoomDetailsBloc(
    this._getRoomDetails,
    this._checkAvailability,
    this._createBooking,
    this._cancelBooking,
  ) : super(const RoomDetailsState()) {
    on<LoadRoomDetailsRequested>(_onLoadRoomDetailsRequested);
    on<DateRangeChanged>(_onDateRangeChanged);
    on<CheckAvailabilityRequested>(_onCheckAvailabilityRequested);
    on<CreateBookingRequested>(_onCreateBookingRequested);
    on<CancelBookingRequested>(_onCancelBookingRequested);
    on<GuestInfoChanged>(_onGuestInfoChanged);
  }

  final GetRoomDetailsUseCase _getRoomDetails;
  final CheckAvailabilityUseCase _checkAvailability;
  final CreateBookingUseCase _createBooking;
  final CancelBookingUseCase _cancelBooking;

  Future<void> _onLoadRoomDetailsRequested(
    LoadRoomDetailsRequested event,
    Emitter<RoomDetailsState> emit,
  ) async {
    emit(state.copyWith(status: RoomDetailsStatus.loading));
    try {
      final result = await _getRoomDetails(event.roomId);

      // Загрузим все конфликтующие брони на большой диапазон,
      // чтобы сразу показать недоступные интервалы.
      // Используем завтрашний день для проверки, чтобы избежать проблем с часовыми поясами
      final DateTime now = DateTime.now();
      final DateTime tomorrowStart = DateTime(now.year, now.month, now.day)
          .add(const Duration(days: 1));
      final info = await _checkAvailability(
        CheckAvailabilityParams(
          roomId: event.roomId,
          start: tomorrowStart,
          end: tomorrowStart.add(const Duration(days: 365)),
        ),
      );

      // Объединяем брони из result.bookings и conflictingBookings
      // conflictingBookings содержит все брони на выбранный период (год вперед)
      final Set<String> bookingIds = <String>{};
      final List<Booking> allBookings = <Booking>[];

      // Добавляем брони из result.bookings (обычно пустой, но на всякий случай)
      for (final Booking booking in result.bookings) {
        if (!bookingIds.contains(booking.id)) {
          bookingIds.add(booking.id);
          allBookings.add(booking);
        }
      }

      // Добавляем брони из conflictingBookings (они содержат все брони на период)
      for (final Booking booking in info.conflictingBookings) {
        if (!bookingIds.contains(booking.id)) {
          bookingIds.add(booking.id);
          allBookings.add(booking);
        }
      }

      // Сортируем брони по дате начала
      allBookings.sort(
        (Booking a, Booking b) => a.startDate.compareTo(b.startDate),
      );

      emit(
        state.copyWith(
          status: RoomDetailsStatus.success,
          room: result.room,
          bookings: allBookings,
          conflictingBookings: info.conflictingBookings,
          errorMessage: null,
          // Сохраняем guestName и guestEmail при загрузке, чтобы не потерять их
          guestName: state.guestName,
          guestEmail: state.guestEmail,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RoomDetailsStatus.failure,
          errorMessage: _mapErrorToMessage(e),
        ),
      );
    }
  }

  void _onDateRangeChanged(
    DateRangeChanged event,
    Emitter<RoomDetailsState> emit,
  ) {
    emit(
      state.copyWith(
        selectedStart: event.start,
        selectedEnd: event.end,
        isAvailable: null,
      ),
    );
  }

  Future<void> _onCheckAvailabilityRequested(
    CheckAvailabilityRequested event,
    Emitter<RoomDetailsState> emit,
  ) async {
    if (state.room == null ||
        state.selectedStart == null ||
        state.selectedEnd == null) {
      return;
    }
    final info = await _checkAvailability(
      CheckAvailabilityParams(
        roomId: state.room!.id,
        start: state.selectedStart!,
        end: state.selectedEnd!,
      ),
    );
    emit(
      state.copyWith(
        isAvailable: info.available,
        conflictingBookings: info.conflictingBookings,
      ),
    );
  }

  Future<void> _onCreateBookingRequested(
    CreateBookingRequested event,
    Emitter<RoomDetailsState> emit,
  ) async {
    if (state.room == null ||
        state.selectedStart == null ||
        state.selectedEnd == null ||
        event.guestName.isEmpty ||
        event.guestEmail.isEmpty) {
      return;
    }
    try {
      final Booking bookingFromApi = await _createBooking(
        CreateBookingParams(
          roomId: state.room!.id,
          start: state.selectedStart!,
          end: state.selectedEnd!,
          guestName: event.guestName,
          guestEmail: event.guestEmail,
        ),
      );
      // Если API не вернул имя, используем из события
      final Booking booking = Booking(
        id: bookingFromApi.id,
        roomId: bookingFromApi.roomId,
        startDate: bookingFromApi.startDate,
        endDate: bookingFromApi.endDate,
        isActive: bookingFromApi.isActive,
        guestName: bookingFromApi.guestName?.isNotEmpty == true
            ? bookingFromApi.guestName
            : event.guestName,
        guestEmail: bookingFromApi.guestEmail?.isNotEmpty == true
            ? bookingFromApi.guestEmail
            : event.guestEmail,
      );
      final List<Booking> updated = List<Booking>.from(state.bookings)
        ..add(booking);

      // Сортируем брони по дате начала
      updated.sort(
        (Booking a, Booking b) => a.startDate.compareTo(b.startDate),
      );

      // Обновляем conflictingBookings, добавляя новую бронь
      final List<Booking> updatedConflicting = List<Booking>.from(
        state.conflictingBookings,
      )..add(booking);
      updatedConflicting.sort(
        (Booking a, Booking b) => a.startDate.compareTo(b.startDate),
      );

      emit(
        RoomDetailsState(
          status: state.status,
          room: state.room,
          bookings: updated,
          selectedStart: null,
          selectedEnd: null,
          isAvailable: null,
          errorMessage: null,
          guestName: state.guestName,
          guestEmail: state.guestEmail,
          conflictingBookings: updatedConflicting,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: _mapErrorToMessage(e)));
    }
  }

  Future<void> _onCancelBookingRequested(
    CancelBookingRequested event,
    Emitter<RoomDetailsState> emit,
  ) async {
    try {
      await _cancelBooking(event.bookingId);

      // Обновляем брони в списке
      final List<Booking> updatedBookings = state.bookings
          .map(
            (Booking b) => b.id == event.bookingId
                ? Booking(
                    id: b.id,
                    roomId: b.roomId,
                    startDate: b.startDate,
                    endDate: b.endDate,
                    isActive: false,
                    guestName: b.guestName,
                    guestEmail: b.guestEmail,
                  )
                : b,
          )
          .toList();

      // Обновляем conflictingBookings
      final List<Booking> updatedConflicting = state.conflictingBookings
          .map(
            (Booking b) => b.id == event.bookingId
                ? Booking(
                    id: b.id,
                    roomId: b.roomId,
                    startDate: b.startDate,
                    endDate: b.endDate,
                    isActive: false,
                    guestName: b.guestName,
                    guestEmail: b.guestEmail,
                  )
                : b,
          )
          .toList();

      emit(
        state.copyWith(
          bookings: updatedBookings,
          conflictingBookings: updatedConflicting,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: _mapErrorToMessage(e)));
    }
  }

  void _onGuestInfoChanged(
    GuestInfoChanged event,
    Emitter<RoomDetailsState> emit,
  ) {
    emit(state.copyWith(guestName: event.name, guestEmail: event.email));
  }
}

String _mapErrorToMessage(Object error) {
  if (error is OperationException && error.graphqlErrors.isNotEmpty) {
    // Берём только человеко-понятное сообщение из GraphQL,
    // без трассировки и прочего шума.
    return error.graphqlErrors.first.message;
  }

  // Фолбэк на случай других ошибок сети/клиента.
  return 'Произошла ошибка при обработке запроса. Попробуйте ещё раз.';
}
