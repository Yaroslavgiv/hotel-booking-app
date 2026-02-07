import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobapp/l10n/app_localizations.dart';
import 'package:mobapp/features/hotels/application/check_availability_use_case.dart';
import 'package:mobapp/features/hotels/application/get_hotels_use_case.dart';
import 'package:mobapp/features/hotels/application/get_rooms_by_hotel_use_case.dart';
import 'package:mobapp/features/hotels/data/datasources/hotel_remote_data_source.dart';
import 'package:mobapp/features/hotels/data/repositories/hotel_repository_impl.dart';
import 'package:mobapp/features/hotels/presentation/bloc/windows_overview/windows_overview_bloc.dart';
import 'package:mobapp/features/hotels/presentation/bloc/windows_overview/windows_overview_event.dart';
import 'package:mobapp/features/hotels/presentation/bloc/windows_overview/windows_overview_state.dart';
import 'package:mobapp/features/hotels/presentation/pages/rooms_page.dart';

class WindowsOverviewPage extends StatelessWidget {
  const WindowsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = HotelRepositoryImpl(HotelRemoteDataSource());
    final getHotels = GetHotelsUseCase(repository);
    final getRoomsByHotel = GetRoomsByHotelUseCase(repository);
    final checkAvailability = CheckAvailabilityUseCase(repository);

    return BlocProvider<WindowsOverviewBloc>(
      create: (_) => WindowsOverviewBloc(
        getHotels,
        getRoomsByHotel,
        checkAvailability,
      )..add(const WindowsOverviewRefreshRequested()),
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.windowsOverviewTitle),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context
                        .read<WindowsOverviewBloc>()
                        .add(const WindowsOverviewRefreshRequested());
                  },
                  tooltip: l10n.buttonRefresh,
                ),
              ],
            ),
            body: BlocBuilder<WindowsOverviewBloc, WindowsOverviewState>(
          builder: (BuildContext context, WindowsOverviewState state) {
            if (state.status == WindowsOverviewStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == WindowsOverviewStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? l10n.errorLoading),
              );
            }

            if (state.status == WindowsOverviewStatus.success) {
              if (state.items.isEmpty) {
                return Center(child: Text(l10n.windowsOverviewEmpty));
              }
              
              // Отладочная информация
              debugPrint('WindowsOverview: Success, items count: ${state.items.length}');
              for (final item in state.items) {
                debugPrint('  - ${item.hotel.name}: free=${item.hasFreeRoomToday}, nextDate=${item.nextAvailableDate}');
              }
              
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = state.items[index];
                  final hotel = item.hotel;
                  final bool free = item.hasFreeRoomToday;
                  
                  // Формируем текстовый статус - всегда показываем что-то
                  String statusText;
                  if (free) {
                    statusText = l10n.statusFreeToday;
                  } else if (item.nextAvailableDate != null) {
                    final DateTime todayStart = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    );
                    final int daysUntil = item.nextAvailableDate!
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
                  
                  debugPrint('Building card for ${hotel.name}: statusText=$statusText');
                  
                  return ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 300,
                      minHeight: 120,
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: InkWell(
                        onTap: () {
                          // При клике открываем обычный экран списка номеров.
                          Navigator.of(context).push(
                            MaterialPageRoute<Widget>(
                              builder: (_) => RoomsPage(hotel: hotel),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: <Widget>[
                            // Изображение отеля
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 80,
                                height: 80,
                                child: Image.asset(
                                  _getHotelImagePath(hotel),
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: free
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                      ),
                                      child: Icon(
                                        free ? Icons.check_circle : Icons.event_busy,
                                        color: free ? Colors.green[700] : Colors.orange[700],
                                        size: 28,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Информация об отеле
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    hotel.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          hotel.address,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Статус доступности - всегда показываем с ярким фоном
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: free
                                          ? Colors.green[50]
                                          : Colors.orange[50],
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: free
                                            ? Colors.green[300]!
                                            : Colors.orange[300]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: free
                                                ? Colors.green[100]
                                                : Colors.orange[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            free
                                                ? Icons.hotel
                                                : Icons.calendar_today,
                                            size: 20,
                                            color: free
                                                ? Colors.green[800]
                                                : Colors.orange[800],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            statusText,
                                            style: TextStyle(
                                              color: free
                                                  ? Colors.green[900]
                                                  : Colors.orange[900],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
            ),
          );
        },
      ),
    );
  }

  /// Получает путь к изображению отеля на основе его названия или адреса
  String _getHotelImagePath(dynamic hotel) {
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
}

