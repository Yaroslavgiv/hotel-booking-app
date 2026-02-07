import 'package:mobapp/features/hotels/domain/repositories/hotel_repository.dart';

class CancelBookingUseCase {
  const CancelBookingUseCase(this._repository);

  final HotelRepository _repository;

  Future<void> call(String bookingId) {
    return _repository.cancelBooking(bookingId);
  }
}

