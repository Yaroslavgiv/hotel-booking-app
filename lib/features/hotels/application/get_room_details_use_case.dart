import 'package:mobapp/features/hotels/domain/entities/booking.dart';
import 'package:mobapp/features/hotels/domain/entities/room.dart';
import 'package:mobapp/features/hotels/domain/repositories/hotel_repository.dart';

class GetRoomDetailsResult {
  const GetRoomDetailsResult({
    required this.room,
    required this.bookings,
  });

  final Room room;
  final List<Booking> bookings;
}

class GetRoomDetailsUseCase {
  const GetRoomDetailsUseCase(this._repository);

  final HotelRepository _repository;

  Future<GetRoomDetailsResult> call(String roomId) async {
    final Room room = await _repository.getRoomById(roomId);
    final List<Booking> bookings = await _repository.getRoomBookings(roomId);
    return GetRoomDetailsResult(room: room, bookings: bookings);
  }
}

