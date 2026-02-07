import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobapp/core/config/app_config.dart';
import 'package:mobapp/features/hotels/domain/entities/booking.dart';
import 'package:mobapp/features/hotels/domain/entities/hotel.dart';
import 'package:mobapp/features/hotels/domain/entities/room.dart';
import 'package:mobapp/features/hotels/domain/value_objects/availability_info.dart';

/// Реальный remote data source, работающий с GraphQL-схемой Backend.
class HotelRemoteDataSource {
  HotelRemoteDataSource()
    : _client = ValueNotifier<GraphQLClient>(
        GraphQLClient(
          link: HttpLink(AppConfig.graphQLEndpoint),
          cache: GraphQLCache(),
        ),
      );

  final ValueNotifier<GraphQLClient> _client;

  GraphQLClient get client => _client.value;

  /// -----------------
  /// GraphQL запросы
  /// -----------------

  static const String _getHotelsQuery = r'''
query GetHotels {
  hotels {
    id
    name
    address
    description
  }
}
''';

  static const String _getRoomsByHotelQuery = r'''
query GetRoomsByHotel($hotelId: ID!) {
  roomsByHotel(hotelId: $hotelId) {
    id
    number
    type
    price
    hotelId
  }
}
''';

  static const String _getRoomsQuery = r'''
query GetRooms {
  rooms {
    id
    number
    type
    price
    hotel {
      id
    }
  }
}
''';

  static const String _checkAvailabilityQuery = r'''
query CheckAvailability($roomId: ID!, $checkIn: String!, $checkOut: String!) {
  checkAvailability(roomId: $roomId, checkIn: $checkIn, checkOut: $checkOut) {
    available
    conflictingBookings {
      id
      guestName
      guestEmail
      checkIn
      checkOut
      roomId
      isActive
    }
  }
}
''';

  static const String _createBookingMutation = r'''
mutation CreateBooking($input: CreateBookingInput!) {
  createBooking(input: $input) {
    id
    guestName
    guestEmail
    checkIn
    checkOut
    roomId
    isActive
  }
}
''';

  static const String _cancelBookingMutation = r'''
mutation CancelBooking($id: ID!) {
  cancelBooking(id: $id) {
    id
    isActive
    roomId
    checkIn
    checkOut
    guestName
    guestEmail
  }
}
''';

  /// -----------------
  /// Мапперы
  /// -----------------

  Hotel _mapHotel(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      description: json['description'] as String?,
    );
  }

  Room _mapRoom(Map<String, dynamic> json) {
    final Map<String, dynamic>? hotelJson =
        json['hotel'] as Map<String, dynamic>?;
    return Room(
      id: json['id'] as String,
      hotelId: (json['hotelId'] ?? hotelJson?['id']) as String,
      number: json['number'] as String,
      type: json['type'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Booking _mapBooking(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic value) {
      // Бэкенд может вернуть:
      // - ISO-строку даты,
      // - timestamp в миллисекундах (как число или строка).
      if (value is String) {
        final String trimmed = value.trim();
        final bool looksLikeNumber = RegExp(r'^\d+$').hasMatch(trimmed);
        if (looksLikeNumber) {
          return DateTime.fromMillisecondsSinceEpoch(
            int.parse(trimmed),
            isUtc: true,
          );
        }
        return DateTime.parse(trimmed);
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
      }
      if (value is num) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
      }
      throw FormatException('Unsupported date format', value.toString());
    }

    final dynamic checkInRaw = json['checkIn'];
    final dynamic checkOutRaw = json['checkOut'];

    return Booking(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      startDate: _parseDate(checkInRaw),
      endDate: _parseDate(checkOutRaw),
      isActive: json['isActive'] as bool,
      guestName: json['guestName'] as String?,
      guestEmail: json['guestEmail'] as String?,
    );
  }

  /// -----------------
  /// Методы API
  /// -----------------

  Future<List<Hotel>> fetchHotels() async {
    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(_getHotelsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final List<dynamic> hotelsJson =
        (result.data?['hotels'] as List<dynamic>? ?? <dynamic>[]);

    return hotelsJson
        .map((dynamic h) => _mapHotel(h as Map<String, dynamic>))
        .toList();
  }

  Future<List<Room>> fetchRooms(String hotelId) async {
    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(_getRoomsByHotelQuery),
        fetchPolicy: FetchPolicy.networkOnly,
        variables: <String, dynamic>{'hotelId': hotelId},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final List<dynamic> roomsJson =
        (result.data?['roomsByHotel'] as List<dynamic>? ?? <dynamic>[]);

    return roomsJson
        .map((dynamic r) => _mapRoom(r as Map<String, dynamic>))
        .toList();
  }

  Future<Room> fetchRoomById(String roomId) async {
    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(_getRoomsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final List<dynamic> roomsJson =
        (result.data?['rooms'] as List<dynamic>? ?? <dynamic>[]);

    final Map<String, dynamic>? roomJson = roomsJson
        .cast<Map<String, dynamic>>()
        .firstWhere((Map<String, dynamic> r) => r['id'] == roomId);

    if (roomJson == null) {
      throw Exception('Room not found');
    }

    return _mapRoom(roomJson);
  }

  /// В GraphQL-схеме нет отдельного запроса для "все брони номера",
  /// поэтому на первом шаге просто возвращаем пустой список.
  /// Фактические брони появятся в состоянии после createBooking/cancelBooking.
  Future<List<Booking>> fetchRoomBookings(String roomId) async {
    return <Booking>[];
  }

  Future<AvailabilityInfo> checkAvailability({
    required String roomId,
    required DateTime start,
    required DateTime end,
  }) async {
    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(_checkAvailabilityQuery),
        fetchPolicy: FetchPolicy.networkOnly,
        variables: <String, dynamic>{
          'roomId': roomId,
          'checkIn': start.toIso8601String().split('T').first,
          'checkOut': end.toIso8601String().split('T').first,
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final Map<String, dynamic> data =
        result.data?['checkAvailability'] as Map<String, dynamic>;

    final bool available = data['available'] as bool;
    final List<dynamic> conflictsJson =
        (data['conflictingBookings'] as List<dynamic>? ?? <dynamic>[]);

    final List<Booking> conflicts = conflictsJson
        .map((dynamic b) => _mapBooking(b as Map<String, dynamic>))
        .toList();

    return AvailabilityInfo(
      available: available,
      conflictingBookings: conflicts,
    );
  }

  Future<Booking> createBooking({
    required String roomId,
    required DateTime start,
    required DateTime end,
    required String guestName,
    required String guestEmail,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(_createBookingMutation),
      variables: <String, dynamic>{
        'input': <String, dynamic>{
          'roomId': roomId,
          'guestName': guestName,
          'guestEmail': guestEmail,
          'checkIn': start.toIso8601String().split('T').first,
          'checkOut': end.toIso8601String().split('T').first,
        },
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }

    // С fetchPolicy: FetchPolicy.networkOnly кэш не используется,
    // поэтому данные всегда будут свежими

    final Map<String, dynamic> bookingJson =
        result.data?['createBooking'] as Map<String, dynamic>;

    return _mapBooking(bookingJson);
  }

  Future<void> cancelBooking(String bookingId) async {
    final MutationOptions options = MutationOptions(
      document: gql(_cancelBookingMutation),
      variables: <String, dynamic>{'id': bookingId},
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }

    // С fetchPolicy: FetchPolicy.networkOnly кэш не используется,
    // поэтому данные всегда будут свежими
  }
}
