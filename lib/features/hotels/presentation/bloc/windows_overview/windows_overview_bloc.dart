import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobapp/features/hotels/application/check_availability_use_case.dart';
import 'package:mobapp/features/hotels/application/get_hotels_use_case.dart';
import 'package:mobapp/features/hotels/application/get_rooms_by_hotel_use_case.dart';
import 'package:mobapp/features/hotels/domain/entities/hotel.dart';
import 'package:mobapp/features/hotels/domain/entities/room.dart';
import 'package:mobapp/features/hotels/domain/value_objects/availability_info.dart';

import 'windows_overview_event.dart';
import 'windows_overview_state.dart';

class WindowsOverviewBloc
    extends Bloc<WindowsOverviewEvent, WindowsOverviewState> {
  WindowsOverviewBloc(
    this._getHotels,
    this._getRoomsByHotel,
    this._checkAvailability,
  ) : super(const WindowsOverviewState()) {
    on<WindowsOverviewRefreshRequested>(_onRefreshRequested);
  }

  final GetHotelsUseCase _getHotels;
  final GetRoomsByHotelUseCase _getRoomsByHotel;
  final CheckAvailabilityUseCase _checkAvailability;

  Future<void> _onRefreshRequested(
    WindowsOverviewRefreshRequested event,
    Emitter<WindowsOverviewState> emit,
  ) async {
    emit(state.copyWith(status: WindowsOverviewStatus.loading));
    try {
      final List<Hotel> hotels = await _getHotels();
      final List<Hotel> picked = hotels.take(2).toList();

      final DateTime now = DateTime.now();
      final DateTime todayStart =
          DateTime(now.year, now.month, now.day); // 00:00
      final DateTime todayEnd =
          todayStart.add(const Duration(days: 1)); // +1 день

      final List<HotelTodayStatus> statuses = <HotelTodayStatus>[];

      for (final Hotel hotel in picked) {
        bool hasFree = false;
        DateTime? nextAvailableDate;

        try {
          final List<Room> rooms =
              await _getRoomsByHotel(hotel.id);

          // Если нет номеров, помечаем как занято
          if (rooms.isEmpty) {
            statuses.add(
              HotelTodayStatus(
                hotel: hotel,
                hasFreeRoomToday: false,
                nextAvailableDate: null,
              ),
            );
            continue;
          }

          // Проверяем доступность на сегодня - проверяем только первый номер для скорости
          try {
            final AvailabilityInfo info =
                await _checkAvailability(
              CheckAvailabilityParams(
                roomId: rooms.first.id,
                start: todayStart,
                end: todayEnd,
              ),
            );
            hasFree = info.available;
          } catch (e) {
            // Если ошибка при проверке, считаем что занято
            hasFree = false;
          }

          // Если сегодня занято, ищем ближайшую свободную дату (только для первого номера)
          if (!hasFree) {
            try {
              for (int dayOffset = 1; dayOffset <= 30; dayOffset++) {
                final DateTime checkDate = todayStart.add(Duration(days: dayOffset));
                final DateTime checkDateEnd = checkDate.add(const Duration(days: 1));

                try {
                  final AvailabilityInfo info =
                      await _checkAvailability(
                    CheckAvailabilityParams(
                      roomId: rooms.first.id,
                      start: checkDate,
                      end: checkDateEnd,
                    ),
                  );
                  if (info.available) {
                    nextAvailableDate = checkDate;
                    break;
                  }
                } catch (e) {
                  // Пропускаем эту дату при ошибке
                  continue;
                }
              }
            } catch (e) {
              // Если ошибка при поиске, оставляем nextAvailableDate = null
            }
          }
        } catch (e) {
          // Если ошибка при получении номеров, помечаем как занято
          hasFree = false;
          nextAvailableDate = null;
        }

        statuses.add(
          HotelTodayStatus(
            hotel: hotel,
            hasFreeRoomToday: hasFree,
            nextAvailableDate: nextAvailableDate,
          ),
        );
      }

      emit(
        state.copyWith(
          status: WindowsOverviewStatus.success,
          items: statuses,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WindowsOverviewStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

