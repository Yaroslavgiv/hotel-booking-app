import 'package:equatable/equatable.dart';
import 'package:mobapp/features/hotels/domain/entities/room.dart';

enum RoomsStatus { initial, loading, success, failure }

class RoomsState extends Equatable {
  const RoomsState({
    this.status = RoomsStatus.initial,
    this.rooms = const [],
    this.allRooms = const [],
    this.minPrice,
    this.maxPrice,
    this.selectedType,
    this.filterStart,
    this.filterEnd,
    this.errorMessage,
  });

  final RoomsStatus status;
  final List<Room> rooms;
  final List<Room> allRooms;
  final double? minPrice;
  final double? maxPrice;
  final String? selectedType;
  final DateTime? filterStart;
  final DateTime? filterEnd;
  final String? errorMessage;

  RoomsState copyWith({
    RoomsStatus? status,
    List<Room>? rooms,
    List<Room>? allRooms,
    double? minPrice,
    double? maxPrice,
    String? selectedType,
    DateTime? filterStart,
    DateTime? filterEnd,
    String? errorMessage,
  }) {
    return RoomsState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      allRooms: allRooms ?? this.allRooms,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      selectedType: selectedType ?? this.selectedType,
      filterStart: filterStart ?? this.filterStart,
      filterEnd: filterEnd ?? this.filterEnd,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        rooms,
        allRooms,
        minPrice,
        maxPrice,
        selectedType,
        filterStart,
        filterEnd,
        errorMessage,
      ];
}

