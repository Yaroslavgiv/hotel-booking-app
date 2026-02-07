import 'package:equatable/equatable.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoomsRequested extends RoomsEvent {
  const LoadRoomsRequested(this.hotelId);

  final String hotelId;

  @override
  List<Object?> get props => [hotelId];
}

class RoomsFilterUpdated extends RoomsEvent {
  const RoomsFilterUpdated({
    this.minPrice,
    this.maxPrice,
    this.selectedType,
    this.filterStart,
    this.filterEnd,
  });

  final double? minPrice;
  final double? maxPrice;
  final String? selectedType;
  final DateTime? filterStart;
  final DateTime? filterEnd;

  @override
  List<Object?> get props =>
      [minPrice, maxPrice, selectedType, filterStart, filterEnd];
}

