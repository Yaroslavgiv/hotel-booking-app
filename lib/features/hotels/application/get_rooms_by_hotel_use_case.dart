import 'package:mobapp/features/hotels/domain/entities/room.dart';
import 'package:mobapp/features/hotels/domain/repositories/hotel_repository.dart';

class GetRoomsByHotelUseCase {
  const GetRoomsByHotelUseCase(this._repository);

  final HotelRepository _repository;

  Future<List<Room>> call(String hotelId) {
    return _repository.getRooms(hotelId);
  }
}

