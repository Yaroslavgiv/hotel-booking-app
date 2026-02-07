import 'package:mobapp/features/hotels/data/datasources/hotel_remote_data_source.dart';
import 'package:mobapp/features/hotels/domain/entities/booking.dart';
import 'package:mobapp/features/hotels/domain/entities/hotel.dart';
import 'package:mobapp/features/hotels/domain/entities/room.dart';
import 'package:mobapp/features/hotels/domain/repositories/hotel_repository.dart';
import 'package:mobapp/features/hotels/domain/value_objects/availability_info.dart';

class HotelRepositoryImpl implements HotelRepository {
  HotelRepositoryImpl(this._remote);

  final HotelRemoteDataSource _remote;

  @override
  Future<List<Hotel>> getHotels() => _remote.fetchHotels();

  @override
  Future<List<Room>> getRooms(String hotelId) => _remote.fetchRooms(hotelId);

  @override
  Future<Room> getRoomById(String roomId) => _remote.fetchRoomById(roomId);

  @override
  Future<List<Booking>> getRoomBookings(String roomId) =>
      _remote.fetchRoomBookings(roomId);

  @override
  Future<AvailabilityInfo> checkAvailability({
    required String roomId,
    required DateTime start,
    required DateTime end,
  }) async {
    return _remote.checkAvailability(
      roomId: roomId,
      start: start,
      end: end,
    );
  }

  @override
  Future<Booking> createBooking({
    required String roomId,
    required DateTime start,
    required DateTime end,
    required String guestName,
    required String guestEmail,
  }) =>
      _remote.createBooking(
        roomId: roomId,
        start: start,
        end: end,
        guestName: guestName,
        guestEmail: guestEmail,
      );

  @override
  Future<void> cancelBooking(String bookingId) =>
      _remote.cancelBooking(bookingId);
}

