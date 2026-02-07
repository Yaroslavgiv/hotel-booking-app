import 'package:mobapp/features/hotels/domain/entities/hotel.dart';
import 'package:mobapp/features/hotels/domain/repositories/hotel_repository.dart';

class GetHotelsUseCase {
  const GetHotelsUseCase(this._repository);

  final HotelRepository _repository;

  Future<List<Hotel>> call() {
    return _repository.getHotels();
  }
}

