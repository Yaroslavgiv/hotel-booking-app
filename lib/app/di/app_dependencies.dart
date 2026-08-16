import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_booking_app/features/hotels/application/cancel_booking_use_case.dart';
import 'package:hotel_booking_app/features/hotels/application/check_availability_use_case.dart';
import 'package:hotel_booking_app/features/hotels/application/create_booking_use_case.dart';
import 'package:hotel_booking_app/features/hotels/application/get_hotels_use_case.dart';
import 'package:hotel_booking_app/features/hotels/application/get_room_details_use_case.dart';
import 'package:hotel_booking_app/features/hotels/application/get_rooms_by_hotel_use_case.dart';
import 'package:hotel_booking_app/features/hotels/data/datasources/hotel_remote_data_source.dart';
import 'package:hotel_booking_app/features/hotels/data/repositories/hotel_repository_impl.dart';
import 'package:hotel_booking_app/features/hotels/domain/repositories/hotel_repository.dart';

class AppDependencies extends StatelessWidget {
  const AppDependencies({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HotelRemoteDataSource>(
          create: (_) => HotelRemoteDataSource(),
        ),
        RepositoryProvider<HotelRepository>(
          create: (BuildContext context) =>
              HotelRepositoryImpl(context.read<HotelRemoteDataSource>()),
        ),
        RepositoryProvider<GetHotelsUseCase>(
          create: (BuildContext context) =>
              GetHotelsUseCase(context.read<HotelRepository>()),
        ),
        RepositoryProvider<GetRoomsByHotelUseCase>(
          create: (BuildContext context) =>
              GetRoomsByHotelUseCase(context.read<HotelRepository>()),
        ),
        RepositoryProvider<GetRoomDetailsUseCase>(
          create: (BuildContext context) =>
              GetRoomDetailsUseCase(context.read<HotelRepository>()),
        ),
        RepositoryProvider<CheckAvailabilityUseCase>(
          create: (BuildContext context) =>
              CheckAvailabilityUseCase(context.read<HotelRepository>()),
        ),
        RepositoryProvider<CreateBookingUseCase>(
          create: (BuildContext context) =>
              CreateBookingUseCase(context.read<HotelRepository>()),
        ),
        RepositoryProvider<CancelBookingUseCase>(
          create: (BuildContext context) =>
              CancelBookingUseCase(context.read<HotelRepository>()),
        ),
      ],
      child: child,
    );
  }
}
