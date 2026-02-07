import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobapp/features/hotels/application/check_availability_use_case.dart';
import 'package:mobapp/features/hotels/application/get_hotels_use_case.dart';
import 'package:mobapp/features/hotels/application/get_rooms_by_hotel_use_case.dart';
import 'package:mobapp/features/hotels/data/datasources/hotel_remote_data_source.dart';
import 'package:mobapp/features/hotels/data/repositories/hotel_repository_impl.dart';
import 'package:mobapp/features/hotels/domain/entities/hotel.dart';
import 'package:mobapp/features/hotels/presentation/bloc/hotels/hotels_bloc.dart';
import 'package:mobapp/features/hotels/presentation/bloc/hotels/hotels_event.dart';
import 'package:mobapp/features/hotels/presentation/bloc/hotels/hotels_state.dart';
import 'package:mobapp/features/hotels/presentation/pages/rooms_page.dart';
import 'package:mobapp/l10n/app_localizations.dart';

class HotelsPage extends StatelessWidget {
  const HotelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = HotelRepositoryImpl(HotelRemoteDataSource());
    final GetHotelsUseCase getHotels = GetHotelsUseCase(repository);
    final GetRoomsByHotelUseCase getRoomsByHotel = GetRoomsByHotelUseCase(
      repository,
    );
    final CheckAvailabilityUseCase checkAvailability = CheckAvailabilityUseCase(
      repository,
    );

    final Color primary = Theme.of(context).colorScheme.primary;
    final Color onPrimary = Theme.of(context).colorScheme.onPrimary;

    return BlocProvider<HotelsBloc>(
      create: (_) =>
          HotelsBloc(getHotels, getRoomsByHotel, checkAvailability)
            ..add(const LoadHotelsRequested()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 320,
                  minHeight: 400,
                ),
                child: BlocBuilder<HotelsBloc, HotelsState>(
            builder: (BuildContext context, HotelsState state) {
              if (state.status == HotelsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == HotelsStatus.failure) {
                return _HotelsError(
                  message: state.errorMessage ?? l10n.errorLoading,
                );
              }

              if (state.status == HotelsStatus.success &&
                  state.hotels.isEmpty) {
                return _HotelsError(message: l10n.hotelsEmpty);
              }

              final List<Hotel> hotels = state.hotels;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _HotelsHeader(primary: primary, onPrimary: onPrimary),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Text(
                      l10n.hotelsTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      itemCount: hotels.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Hotel hotel = hotels[index];
                        final HotelAvailabilityStatus? availabilityStatus =
                            state.availabilityStatuses[hotel.id];
                        return _HotelCard(
                          hotel: hotel,
                          primary: primary,
                          availabilityStatus: availabilityStatus,
                          onRefreshStatus: () {
                            context
                                .read<HotelsBloc>()
                                .add(CheckAvailabilityRequested(hotelId: hotel.id));
                          },
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<Widget>(
                                builder: (_) => RoomsPage(hotel: hotel),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HotelsHeader extends StatelessWidget {
  const _HotelsHeader({required this.primary, required this.onPrimary});

  final Color primary;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[primary, primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: onPrimary.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Найдите отель для следующей поездки',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: onPrimary.withOpacity(0.15),
                child: Icon(
                  Icons.location_on_outlined,
                  color: onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                Icon(Icons.search, color: onPrimary.withOpacity(0.9)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: onPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Поиск отеля, города...',
                      hintStyle: TextStyle(color: onPrimary.withOpacity(0.7)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  const _HotelCard({
    required this.hotel,
    required this.primary,
    required this.onTap,
    this.availabilityStatus,
    this.onRefreshStatus,
  });

  final Hotel hotel;
  final Color primary;
  final VoidCallback onTap;
  final HotelAvailabilityStatus? availabilityStatus;
  final VoidCallback? onRefreshStatus;

  /// Получает путь к изображению отеля на основе его названия или адреса
  String _getHotelImagePath() {
    final String name = hotel.name.toLowerCase();
    final String address = hotel.address.toLowerCase();

    if (name.contains('hartwell') || address.contains('hartwell')) {
      return 'assets/images/Hartwell.jpg';
    }
    if (name.contains('москва') || address.contains('москва') || address.contains('moscow')) {
      return 'assets/images/moscow.jpg';
    }
    if (name.contains('петербург') || name.contains('petersburg') || 
        address.contains('петербург') || address.contains('petersburg') ||
        address.contains('piter')) {
      return 'assets/images/Saint-Petersburg.jpg';
    }
    // Дефолтное изображение
    return 'assets/images/hotel.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  height: 160,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      // Фоновое изображение
                      Image.asset(
                        _getHotelImagePath(),
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  primary.withOpacity(0.95),
                                  primary.withOpacity(0.75),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          );
                        },
                      ),
                      // Затемнение для читаемости текста
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              hotel.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    hotel.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Статус доступности - показываем всегда, даже если еще загружается
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: availabilityStatus != null
                          ? _buildAvailabilityStatus(context, availabilityStatus!)
                          : _buildLoadingStatus(context),
                    ),
                    if (onRefreshStatus != null) ...<Widget>[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        color: primary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        onPressed: onRefreshStatus,
                        tooltip: AppLocalizations.of(context)!.buttonRefresh,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: const <Widget>[
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text('Рекомендуем'),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Смотреть номера',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityStatus(
    BuildContext context,
    HotelAvailabilityStatus status,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final bool free = status.hasFreeRoomToday;

    String statusText;
    if (free) {
      statusText = l10n.statusFreeToday;
    } else if (status.nextAvailableDate != null) {
      final DateTime todayStart = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      final int daysUntil = status.nextAvailableDate!
          .difference(todayStart)
          .inDays;
      if (daysUntil == 1) {
        statusText = l10n.statusNextBookingTomorrow;
      } else if (daysUntil > 1) {
        statusText = l10n.statusNextBookingDays(daysUntil);
      } else {
        statusText = l10n.statusBusyToday;
      }
    } else {
      statusText = l10n.statusBusyToday;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: free ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: free ? Colors.green[300]! : Colors.orange[300]!,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            free ? Icons.hotel : Icons.calendar_today,
            size: 16,
            color: free ? Colors.green[800] : Colors.orange[800],
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              statusText,
              style: TextStyle(
                color: free ? Colors.green[900] : Colors.orange[900],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Проверка доступности...',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelsError extends StatelessWidget {
  const _HotelsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
