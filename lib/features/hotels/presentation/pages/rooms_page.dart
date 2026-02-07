import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobapp/l10n/app_localizations.dart';
import 'package:mobapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobapp/features/hotels/application/get_rooms_by_hotel_use_case.dart';
import 'package:mobapp/features/hotels/data/datasources/hotel_remote_data_source.dart';
import 'package:mobapp/features/hotels/data/repositories/hotel_repository_impl.dart';
import 'package:mobapp/features/hotels/domain/entities/hotel.dart';
import 'package:mobapp/features/hotels/domain/entities/room.dart';
import 'package:mobapp/features/hotels/presentation/bloc/rooms/rooms_bloc.dart';
import 'package:mobapp/features/hotels/presentation/bloc/rooms/rooms_event.dart';
import 'package:mobapp/features/hotels/presentation/bloc/rooms/rooms_state.dart';
import 'package:mobapp/features/hotels/presentation/pages/room_details_page.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage({required this.hotel, super.key});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = HotelRepositoryImpl(HotelRemoteDataSource());
    final getRoomsByHotel = GetRoomsByHotelUseCase(repository);

    final Color primary = Theme.of(context).colorScheme.primary;

    return BlocProvider<RoomsBloc>(
      create: (_) => RoomsBloc(getRoomsByHotel)
        ..add(LoadRoomsRequested(hotel.id)),
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
                child: Column(
                  children: <Widget>[
              _RoomsHeader(hotel: hotel, primary: primary),
              const _RoomsFilterBar(),
              Expanded(
                child: BlocBuilder<RoomsBloc, RoomsState>(
                  builder: (BuildContext context, RoomsState state) {
                    if (state.status == RoomsStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == RoomsStatus.failure) {
                      return Center(
                        child: Text(state.errorMessage ?? l10n.errorLoading),
                      );
                    }

                    if (state.rooms.isEmpty) {
                      return Center(child: Text(l10n.roomsEmpty));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: state.rooms.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Room room = state.rooms[index];
                        return _RoomCard(
                          room: room,
                          hotel: hotel,
                          primary: primary,
                          onTap: () {
                            final authBloc = context.read<AuthBloc>();
                            Navigator.of(context).push(
                              MaterialPageRoute<Widget>(
                                builder: (_) => BlocProvider<AuthBloc>.value(
                                  value: authBloc,
                                  child: RoomDetailsPage(roomId: room.id),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoomsHeader extends StatelessWidget {
  const _RoomsHeader({
    required this.hotel,
    required this.primary,
  });

  final Hotel hotel;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[primary, primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Кнопка "Назад"
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Отель',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hotel.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
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
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.king_bed_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.hotel,
    required this.primary,
    required this.onTap,
  });

  final Room room;
  final Hotel hotel;
  final Color primary;
  final VoidCallback onTap;

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
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Container(
                  height: 130,
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
                                  primary.withOpacity(0.7),
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
                              'Номер ${room.number}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              room.type,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${room.price.toStringAsFixed(0)} ₽',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'за ночь',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Выбрать'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomsFilterBar extends StatefulWidget {
  const _RoomsFilterBar();

  @override
  State<_RoomsFilterBar> createState() => _RoomsFilterBarState();
}

class _RoomsFilterBarState extends State<_RoomsFilterBar> {
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String? _selectedType;

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilter(BuildContext context, RoomsState state) {
    final double? minPrice =
        double.tryParse(_minPriceController.text.trim());
    final double? maxPrice =
        double.tryParse(_maxPriceController.text.trim());

    context.read<RoomsBloc>().add(
          RoomsFilterUpdated(
            minPrice: minPrice,
            maxPrice: maxPrice,
            selectedType: _selectedType,
            filterStart: state.filterStart,
            filterEnd: state.filterEnd,
          ),
        );
  }

  Future<void> _pickDates(BuildContext context, RoomsState state) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      context.read<RoomsBloc>().add(
            RoomsFilterUpdated(
              minPrice: state.minPrice,
              maxPrice: state.maxPrice,
              selectedType: state.selectedType,
              filterStart: picked.start,
              filterEnd: picked.end,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<RoomsBloc, RoomsState>(
      builder: (BuildContext context, RoomsState state) {
        final List<String> types = state.allRooms
            .map((Room r) => r.type)
            .toSet()
            .toList();

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      decoration: InputDecoration(
                        labelText: l10n.filtersMinPrice,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      decoration: InputDecoration(
                        labelText: l10n.filtersMaxPrice,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // На узких экранах делаем фильтры в два ряда
                  if (constraints.maxWidth < 400) {
                    return Column(
                      children: <Widget>[
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: l10n.filtersRoomType,
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          value: _selectedType,
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                l10n.filtersAnyType,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ...types.map(
                              (String t) => DropdownMenuItem<String>(
                                value: t,
                                child: Text(
                                  t,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _pickDates(context, state),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(l10n.filtersDates),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _applyFilter(context, state),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(l10n.filtersApply),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  // На широких экранах - в одну строку
                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: l10n.filtersRoomType,
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          value: _selectedType,
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                l10n.filtersAnyType,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ...types.map(
                              (String t) => DropdownMenuItem<String>(
                                value: t,
                                child: Text(
                                  t,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => _pickDates(context, state),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(l10n.filtersDates),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => _applyFilter(context, state),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(l10n.filtersApply),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

