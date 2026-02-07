import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobapp/features/hotels/application/check_availability_use_case.dart';
import 'package:mobapp/features/hotels/application/get_hotels_use_case.dart';
import 'package:mobapp/features/hotels/application/get_rooms_by_hotel_use_case.dart';
import 'package:mobapp/features/hotels/domain/entities/hotel.dart';
import 'package:mobapp/features/hotels/domain/entities/room.dart';

import 'hotels_event.dart';
import 'hotels_state.dart';

class HotelsBloc extends Bloc<HotelsEvent, HotelsState> {
  HotelsBloc(
    this._getHotels,
    this._getRoomsByHotel,
    this._checkAvailability,
  ) : super(const HotelsState()) {
    on<LoadHotelsRequested>(_onLoadHotelsRequested);
    on<CheckAvailabilityRequested>(_onCheckAvailabilityRequested);
    on<RefreshAvailabilityStatusesRequested>(_onRefreshAvailabilityStatusesRequested);
  }

  final GetHotelsUseCase _getHotels;
  final GetRoomsByHotelUseCase _getRoomsByHotel;
  final CheckAvailabilityUseCase _checkAvailability;

  Future<void> _onLoadHotelsRequested(
    LoadHotelsRequested event,
    Emitter<HotelsState> emit,
  ) async {
    emit(state.copyWith(status: HotelsStatus.loading));
    try {
      final List<Hotel> hotels = await _getHotels();
      emit(
        state.copyWith(
          status: HotelsStatus.success,
          hotels: hotels,
          errorMessage: null,
        ),
      );
      // Автоматически проверяем доступность для всех отелей
      for (final Hotel hotel in hotels) {
        add(CheckAvailabilityRequested(hotelId: hotel.id));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: HotelsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCheckAvailabilityRequested(
    CheckAvailabilityRequested event,
    Emitter<HotelsState> emit,
  ) async {
    try {
      final List<Room> rooms = await _getRoomsByHotel(event.hotelId);
      if (rooms.isEmpty) {
        final Map<String, HotelAvailabilityStatus> newStatuses =
            Map<String, HotelAvailabilityStatus>.from(state.availabilityStatuses);
        newStatuses[event.hotelId] = HotelAvailabilityStatus(
          hotelId: event.hotelId,
          hasFreeRoomToday: false,
          nextAvailableDate: null,
        );
        emit(state.copyWith(availabilityStatuses: newStatuses));
        return;
      }

      // Отладочная информация
      debugPrint('Checking availability for hotel ${event.hotelId}, rooms: ${rooms.length}');

      final DateTime now = DateTime.now();
      final DateTime todayStart = DateTime(now.year, now.month, now.day);
      final DateTime todayEnd = todayStart.add(const Duration(days: 1));

      bool hasFree = false;
      DateTime? nextAvailableDate;

      // Проверяем доступность на сегодня - проверяем все номера
      for (final Room room in rooms) {
        try {
          final info = await _checkAvailability(
            CheckAvailabilityParams(
              roomId: room.id,
              start: todayStart,
              end: todayEnd,
            ),
          );
          if (info.available) {
            hasFree = true;
            break; // Если хотя бы один номер свободен, отель свободен
          }
        } catch (e) {
          // Пропускаем этот номер при ошибке
          continue;
        }
      }

      // Если сегодня занято, ищем ближайшую свободную дату
      if (!hasFree) {
        try {
          for (int dayOffset = 1; dayOffset <= 30; dayOffset++) {
            final DateTime checkDate = todayStart.add(Duration(days: dayOffset));
            final DateTime checkDateEnd = checkDate.add(const Duration(days: 1));

            bool foundFree = false;
            // Проверяем все номера на эту дату
            for (final Room room in rooms) {
              try {
                final info = await _checkAvailability(
                  CheckAvailabilityParams(
                    roomId: room.id,
                    start: checkDate,
                    end: checkDateEnd,
                  ),
                );
                if (info.available) {
                  foundFree = true;
                  nextAvailableDate = checkDate;
                  break;
                }
              } catch (e) {
                continue;
              }
            }
            if (foundFree) {
              break;
            }
          }
        } catch (e) {
          // Игнорируем ошибки
        }
      }

      final Map<String, HotelAvailabilityStatus> newStatuses =
          Map<String, HotelAvailabilityStatus>.from(state.availabilityStatuses);
      newStatuses[event.hotelId] = HotelAvailabilityStatus(
        hotelId: event.hotelId,
        hasFreeRoomToday: hasFree,
        nextAvailableDate: nextAvailableDate,
      );
      emit(state.copyWith(availabilityStatuses: newStatuses));
      
      // Отладочная информация
      debugPrint('Hotel ${event.hotelId}: hasFree=$hasFree, nextDate=$nextAvailableDate');
    } catch (e) {
      // Отладочная информация об ошибке
      debugPrint('Error checking availability for hotel ${event.hotelId}: $e');
      // Устанавливаем статус "занято" при ошибке
      final Map<String, HotelAvailabilityStatus> newStatuses =
          Map<String, HotelAvailabilityStatus>.from(state.availabilityStatuses);
      newStatuses[event.hotelId] = HotelAvailabilityStatus(
        hotelId: event.hotelId,
        hasFreeRoomToday: false,
        nextAvailableDate: null,
      );
      emit(state.copyWith(availabilityStatuses: newStatuses));
    }
  }

  Future<void> _onRefreshAvailabilityStatusesRequested(
    RefreshAvailabilityStatusesRequested event,
    Emitter<HotelsState> emit,
  ) async {
    // Обновляем статусы доступности для всех отелей
    if (state.hotels.isEmpty) {
      return;
    }
    
    // Очищаем текущие статусы
    emit(state.copyWith(availabilityStatuses: <String, HotelAvailabilityStatus>{}));
    
    // Проверяем доступность для всех отелей
    for (final Hotel hotel in state.hotels) {
      add(CheckAvailabilityRequested(hotelId: hotel.id));
    }
  }
}

