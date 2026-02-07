import 'package:equatable/equatable.dart';

class Room extends Equatable {
  const Room({
    required this.id,
    required this.hotelId,
    required this.number,
    required this.type,
    required this.price,
  });

  final String id;
  final String hotelId;
  final String number;
  final String type;
  final double price;

  @override
  List<Object?> get props => [id, hotelId, number, type, price];
}

