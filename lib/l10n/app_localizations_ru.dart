// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Приложение отелей';

  @override
  String get authTitle => 'Вход';

  @override
  String get authNameLabel => 'Имя';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authContinue => 'Продолжить';

  @override
  String get errorInvalidAuth => 'Введите корректные имя и email';

  @override
  String get hotelsTitle => 'Отели';

  @override
  String get hotelsEmpty => 'Нет отелей';

  @override
  String roomsTitle(Object hotelName) {
    return 'Номера • $hotelName';
  }

  @override
  String get roomsEmpty => 'Нет номеров';

  @override
  String get roomDetailsTitle => 'Номер';

  @override
  String get statusAvailable => 'Номер доступен';

  @override
  String get statusUnavailable => 'Номер занят';

  @override
  String get conflictingBookingsTitle => 'Недоступные даты брони:';

  @override
  String get bookingActive => 'Активна';

  @override
  String get bookingCancelled => 'Отменена';

  @override
  String get buttonCheck => 'Проверить';

  @override
  String get buttonBook => 'Забронировать';

  @override
  String get buttonCancel => 'Отменить';

  @override
  String get bookingsTitle => 'Брони номера';

  @override
  String get windowsOverviewTitle => 'Отели (Windows Widget)';

  @override
  String get windowsOverviewEmpty => 'Нет данных по отелям';

  @override
  String get buttonRefresh => 'Обновить';

  @override
  String get filtersMinPrice => 'Мин. цена';

  @override
  String get filtersMaxPrice => 'Макс. цена';

  @override
  String get filtersRoomType => 'Тип номера';

  @override
  String get filtersAnyType => 'Любой';

  @override
  String get filtersDates => 'Выбрать даты брони';

  @override
  String get filtersApply => 'Применить';

  @override
  String get errorLoading => 'Ошибка загрузки';

  @override
  String get statusFreeToday => 'Свободно сегодня';

  @override
  String get statusBusyToday => 'Занято сегодня';

  @override
  String get statusNextBookingTomorrow => 'Ближайшая бронь: завтра';

  @override
  String statusNextBookingDays(int days) {
    return 'Ближайшая бронь: через $days дн.';
  }
}
