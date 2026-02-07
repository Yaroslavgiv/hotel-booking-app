// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hotels App';

  @override
  String get authTitle => 'Sign in';

  @override
  String get authNameLabel => 'Name';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authContinue => 'Continue';

  @override
  String get errorInvalidAuth => 'Please enter a valid name and email';

  @override
  String get hotelsTitle => 'Hotels';

  @override
  String get hotelsEmpty => 'No hotels';

  @override
  String roomsTitle(Object hotelName) {
    return 'Rooms • $hotelName';
  }

  @override
  String get roomsEmpty => 'No rooms';

  @override
  String get roomDetailsTitle => 'Room';

  @override
  String get statusAvailable => 'Room is available';

  @override
  String get statusUnavailable => 'Room is not available';

  @override
  String get conflictingBookingsTitle => 'Unavailable booking dates:';

  @override
  String get bookingActive => 'Active';

  @override
  String get bookingCancelled => 'Cancelled';

  @override
  String get buttonCheck => 'Check';

  @override
  String get buttonBook => 'Book';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get bookingsTitle => 'Room bookings';

  @override
  String get windowsOverviewTitle => 'Hotels (Windows Widget)';

  @override
  String get windowsOverviewEmpty => 'No hotel data';

  @override
  String get buttonRefresh => 'Refresh';

  @override
  String get filtersMinPrice => 'Min price';

  @override
  String get filtersMaxPrice => 'Max price';

  @override
  String get filtersRoomType => 'Room type';

  @override
  String get filtersAnyType => 'Any';

  @override
  String get filtersDates => 'Select booking dates';

  @override
  String get filtersApply => 'Apply';

  @override
  String get errorLoading => 'Loading error';

  @override
  String get statusFreeToday => 'Available today';

  @override
  String get statusBusyToday => 'Busy today';

  @override
  String get statusNextBookingTomorrow => 'Next booking: tomorrow';

  @override
  String statusNextBookingDays(int days) {
    return 'Next booking: in $days days';
  }
}
