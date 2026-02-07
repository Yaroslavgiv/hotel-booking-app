import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.roomId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.guestName,
    this.guestEmail,
  });

  final String id;
  final String roomId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? guestName;
  final String? guestEmail;

  @override
  List<Object?> get props =>
      [id, roomId, startDate, endDate, isActive, guestName, guestEmail];
}

