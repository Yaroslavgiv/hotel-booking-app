import 'package:mobapp/features/hotels/domain/entities/hotel.dart';
import 'package:mobapp/features/hotels/domain/entities/room.dart';
import 'package:mobapp/features/hotels/domain/entities/booking.dart';

import 'package:mobapp/features/hotels/domain/value_objects/availability_info.dart';

abstract class HotelRepository {
  Future<List<Hotel>> getHotels();

  Future<List<Room>> getRooms(String hotelId);

  Future<Room> getRoomById(String roomId);

  Future<List<Booking>> getRoomBookings(String roomId);

  Future<AvailabilityInfo> checkAvailability({
    required String roomId,
    required DateTime start,
    required DateTime end,
  });

  Future<Booking> createBooking({
    required String roomId,
    required DateTime start,
    required DateTime end,
    required String guestName,
    required String guestEmail,
  });

  Future<void> cancelBooking(String bookingId);
}

