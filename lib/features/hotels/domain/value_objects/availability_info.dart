import 'package:hotel_booking_app/features/hotels/domain/entities/booking.dart';

class AvailabilityInfo {
  const AvailabilityInfo({
    required this.available,
    required this.conflictingBookings,
  });

  final bool available;
  final List<Booking> conflictingBookings;
}
