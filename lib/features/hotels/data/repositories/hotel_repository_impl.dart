import 'package:hotel_booking_app/core/errors/failure_mapper.dart';
import 'package:hotel_booking_app/features/hotels/data/datasources/hotel_remote_data_source.dart';
import 'package:hotel_booking_app/features/hotels/domain/entities/booking.dart';
import 'package:hotel_booking_app/features/hotels/domain/entities/hotel.dart';
import 'package:hotel_booking_app/features/hotels/domain/entities/room.dart';
import 'package:hotel_booking_app/features/hotels/domain/repositories/hotel_repository.dart';
import 'package:hotel_booking_app/features/hotels/domain/value_objects/availability_info.dart';

class HotelRepositoryImpl implements HotelRepository {
  HotelRepositoryImpl(
    this._remote, {
    FailureMapper failureMapper = const FailureMapper(),
  }) : _failureMapper = failureMapper;

  final HotelRemoteDataSource _remote;
  final FailureMapper _failureMapper;

  @override
  Future<List<Hotel>> getHotels() => _guard(_remote.fetchHotels);

  @override
  Future<List<Room>> getRooms(String hotelId) =>
      _guard(() => _remote.fetchRooms(hotelId));

  @override
  Future<Room> getRoomById(String roomId) =>
      _guard(() => _remote.fetchRoomById(roomId));

  @override
  Future<List<Booking>> getRoomBookings(String roomId) =>
      _guard(() => _remote.fetchRoomBookings(roomId));

  @override
  Future<AvailabilityInfo> checkAvailability({
    required String roomId,
    required DateTime start,
    required DateTime end,
  }) async {
    return _guard(
      () => _remote.checkAvailability(roomId: roomId, start: start, end: end),
    );
  }

  @override
  Future<Booking> createBooking({
    required String roomId,
    required DateTime start,
    required DateTime end,
    required String guestName,
    required String guestEmail,
  }) => _guard(
    () => _remote.createBooking(
      roomId: roomId,
      start: start,
      end: end,
      guestName: guestName,
      guestEmail: guestEmail,
    ),
  );

  @override
  Future<void> cancelBooking(String bookingId) =>
      _guard(() => _remote.cancelBooking(bookingId));

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on Object catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
