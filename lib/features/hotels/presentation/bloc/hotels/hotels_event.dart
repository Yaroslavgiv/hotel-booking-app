import 'package:equatable/equatable.dart';

abstract class HotelsEvent extends Equatable {
  const HotelsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHotelsRequested extends HotelsEvent {
  const LoadHotelsRequested();
}

class CheckAvailabilityRequested extends HotelsEvent {
  const CheckAvailabilityRequested({required this.hotelId});

  final String hotelId;

  @override
  List<Object?> get props => [hotelId];
}

class RefreshAvailabilityStatusesRequested extends HotelsEvent {
  const RefreshAvailabilityStatusesRequested();
}
