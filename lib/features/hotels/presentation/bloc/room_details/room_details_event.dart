import 'package:equatable/equatable.dart';

class RoomDetailsEvent extends Equatable {
  const RoomDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoomDetailsRequested extends RoomDetailsEvent {
  const LoadRoomDetailsRequested(this.roomId);

  final String roomId;

  @override
  List<Object?> get props => [roomId];
}

class DateRangeChanged extends RoomDetailsEvent {
  const DateRangeChanged(this.start, this.end);

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [start, end];
}

class CheckAvailabilityRequested extends RoomDetailsEvent {
  const CheckAvailabilityRequested();
}

class CreateBookingRequested extends RoomDetailsEvent {
  const CreateBookingRequested({
    required this.guestName,
    required this.guestEmail,
  });

  final String guestName;
  final String guestEmail;

  @override
  List<Object?> get props => [guestName, guestEmail];
}

class CancelBookingRequested extends RoomDetailsEvent {
  const CancelBookingRequested(this.bookingId);

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

class GuestInfoChanged extends RoomDetailsEvent {
  const GuestInfoChanged({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  List<Object?> get props => [name, email];
}
