import 'package:equatable/equatable.dart';
import 'package:mobapp/features/hotels/domain/entities/booking.dart';
import 'package:mobapp/features/hotels/domain/entities/room.dart';

enum RoomDetailsStatus { initial, loading, success, failure }

class RoomDetailsState extends Equatable {
  const RoomDetailsState({
    this.status = RoomDetailsStatus.initial,
    this.room,
    this.bookings = const [],
    this.selectedStart,
    this.selectedEnd,
    this.isAvailable,
    this.errorMessage,
    this.guestName,
    this.guestEmail,
    this.conflictingBookings = const <Booking>[],
  });

  final RoomDetailsStatus status;
  final Room? room;
  final List<Booking> bookings;
  final DateTime? selectedStart;
  final DateTime? selectedEnd;
  final bool? isAvailable;
  final String? errorMessage;
  final String? guestName;
  final String? guestEmail;
  final List<Booking> conflictingBookings;

  RoomDetailsState copyWith({
    RoomDetailsStatus? status,
    Room? room,
    List<Booking>? bookings,
    DateTime? selectedStart,
    DateTime? selectedEnd,
    bool? isAvailable,
    String? errorMessage,
    String? guestName,
    String? guestEmail,
    List<Booking>? conflictingBookings,
  }) {
    return RoomDetailsState(
      status: status ?? this.status,
      room: room ?? this.room,
      bookings: bookings ?? this.bookings,
      selectedStart: selectedStart ?? this.selectedStart,
      selectedEnd: selectedEnd ?? this.selectedEnd,
      isAvailable: isAvailable ?? this.isAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      conflictingBookings: conflictingBookings ?? this.conflictingBookings,
    );
  }

  @override
  List<Object?> get props => [
        status,
        room,
        bookings,
        selectedStart,
        selectedEnd,
        isAvailable,
        errorMessage,
        guestName,
        guestEmail,
        conflictingBookings,
      ];
}

