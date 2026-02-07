import 'package:equatable/equatable.dart';

class Hotel extends Equatable {
  const Hotel({
    required this.id,
    required this.name,
    required this.address,
    this.description,
  });

  final String id;
  final String name;
  final String address;
  final String? description;

  @override
  List<Object?> get props => [id, name, address, description];
}

