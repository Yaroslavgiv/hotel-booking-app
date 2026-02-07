import 'package:mobapp/features/hotels/domain/entities/booking.dart';
import 'package:mobapp/features/hotels/domain/repositories/hotel_repository.dart';

class CreateBookingParams {
  const CreateBookingParams({
    required this.roomId,
    required this.start,
    required this.end,
    required this.guestName,
    required this.guestEmail,
  });

  final String roomId;
  final DateTime start;
  final DateTime end;
  final String guestName;
  final String guestEmail;
}

class CreateBookingUseCase {
  const CreateBookingUseCase(this._repository);

  final HotelRepository _repository;

  Future<Booking> call(CreateBookingParams params) {
    return _repository.createBooking(
      roomId: params.roomId,
      start: params.start,
      end: params.end,
      guestName: params.guestName,
      guestEmail: params.guestEmail,
    );
  }
}

