import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobapp/features/hotels/application/get_rooms_by_hotel_use_case.dart';
import 'package:mobapp/features/hotels/domain/entities/room.dart';

import 'rooms_event.dart';
import 'rooms_state.dart';

class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  RoomsBloc(this._getRoomsByHotel) : super(const RoomsState()) {
    on<LoadRoomsRequested>(_onLoadRoomsRequested);
    on<RoomsFilterUpdated>(_onRoomsFilterUpdated);
  }

  final GetRoomsByHotelUseCase _getRoomsByHotel;

  Future<void> _onLoadRoomsRequested(
    LoadRoomsRequested event,
    Emitter<RoomsState> emit,
  ) async {
    emit(state.copyWith(status: RoomsStatus.loading));
    try {
      final List<Room> rooms = await _getRoomsByHotel(event.hotelId);
      emit(
        state.copyWith(
          status: RoomsStatus.success,
          rooms: rooms,
          allRooms: rooms,
          minPrice: null,
          maxPrice: null,
          selectedType: null,
          filterStart: null,
          filterEnd: null,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RoomsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onRoomsFilterUpdated(
    RoomsFilterUpdated event,
    Emitter<RoomsState> emit,
  ) {
    List<Room> filtered = List<Room>.from(state.allRooms);

    if (event.minPrice != null) {
      filtered = filtered
          .where((Room r) => r.price >= event.minPrice!)
          .toList();
    }
    if (event.maxPrice != null) {
      filtered = filtered
          .where((Room r) => r.price <= event.maxPrice!)
          .toList();
    }
    if (event.selectedType != null && event.selectedType!.isNotEmpty) {
      filtered = filtered
          .where((Room r) => r.type == event.selectedType)
          .toList();
    }

    emit(
      state.copyWith(
        rooms: filtered,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        selectedType: event.selectedType,
        filterStart: event.filterStart,
        filterEnd: event.filterEnd,
      ),
    );
  }
}

