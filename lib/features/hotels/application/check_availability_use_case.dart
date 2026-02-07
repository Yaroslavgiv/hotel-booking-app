import 'package:mobapp/features/hotels/domain/repositories/hotel_repository.dart';
import 'package:mobapp/features/hotels/domain/value_objects/availability_info.dart';

class CheckAvailabilityParams {
  const CheckAvailabilityParams({
    required this.roomId,
    required this.start,
    required this.end,
  });

  final String roomId;
  final DateTime start;
  final DateTime end;
}

class CheckAvailabilityUseCase {
  const CheckAvailabilityUseCase(this._repository);

  final HotelRepository _repository;

  Future<AvailabilityInfo> call(CheckAvailabilityParams params) {
    return _repository.checkAvailability(
      roomId: params.roomId,
      start: params.start,
      end: params.end,
    );
  }
}

