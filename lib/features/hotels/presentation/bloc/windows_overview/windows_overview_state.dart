import 'package:equatable/equatable.dart';
import 'package:mobapp/features/hotels/domain/entities/hotel.dart';

enum WindowsOverviewStatus { initial, loading, success, failure }

class HotelTodayStatus extends Equatable {
  const HotelTodayStatus({
    required this.hotel,
    required this.hasFreeRoomToday,
    this.nextAvailableDate,
  });

  final Hotel hotel;
  final bool hasFreeRoomToday;
  final DateTime? nextAvailableDate;

  @override
  List<Object?> get props => [hotel, hasFreeRoomToday, nextAvailableDate];
}

class WindowsOverviewState extends Equatable {
  const WindowsOverviewState({
    this.status = WindowsOverviewStatus.initial,
    this.items = const <HotelTodayStatus>[],
    this.errorMessage,
  });

  final WindowsOverviewStatus status;
  final List<HotelTodayStatus> items;
  final String? errorMessage;

  WindowsOverviewState copyWith({
    WindowsOverviewStatus? status,
    List<HotelTodayStatus>? items,
    String? errorMessage,
  }) {
    return WindowsOverviewState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}

