import 'package:equatable/equatable.dart';
import 'package:mobapp/features/hotels/domain/entities/hotel.dart';

enum HotelsStatus { initial, loading, success, failure }

class HotelAvailabilityStatus extends Equatable {
  const HotelAvailabilityStatus({
    required this.hotelId,
    required this.hasFreeRoomToday,
    this.nextAvailableDate,
  });

  final String hotelId;
  final bool hasFreeRoomToday;
  final DateTime? nextAvailableDate;

  @override
  List<Object?> get props => [hotelId, hasFreeRoomToday, nextAvailableDate];
}

class HotelsState extends Equatable {
  const HotelsState({
    this.status = HotelsStatus.initial,
    this.hotels = const [],
    this.errorMessage,
    this.availabilityStatuses = const {},
  });

  final HotelsStatus status;
  final List<Hotel> hotels;
  final String? errorMessage;
  final Map<String, HotelAvailabilityStatus> availabilityStatuses;

  HotelsState copyWith({
    HotelsStatus? status,
    List<Hotel>? hotels,
    String? errorMessage,
    Map<String, HotelAvailabilityStatus>? availabilityStatuses,
  }) {
    return HotelsState(
      status: status ?? this.status,
      hotels: hotels ?? this.hotels,
      errorMessage: errorMessage ?? this.errorMessage,
      availabilityStatuses: availabilityStatuses ?? this.availabilityStatuses,
    );
  }

  @override
  List<Object?> get props => [status, hotels, errorMessage, availabilityStatuses];
}

