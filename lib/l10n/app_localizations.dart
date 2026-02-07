import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Приложение отелей'**
  String get appTitle;

  /// No description provided for @authTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get authTitle;

  /// No description provided for @authNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get authNameLabel;

  /// No description provided for @authEmailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authContinue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get authContinue;

  /// No description provided for @errorInvalidAuth.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректные имя и email'**
  String get errorInvalidAuth;

  /// No description provided for @hotelsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отели'**
  String get hotelsTitle;

  /// No description provided for @hotelsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет отелей'**
  String get hotelsEmpty;

  /// No description provided for @roomsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Номера • {hotelName}'**
  String roomsTitle(Object hotelName);

  /// No description provided for @roomsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет номеров'**
  String get roomsEmpty;

  /// No description provided for @roomDetailsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Номер'**
  String get roomDetailsTitle;

  /// No description provided for @statusAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Номер доступен'**
  String get statusAvailable;

  /// No description provided for @statusUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Номер занят'**
  String get statusUnavailable;

  /// No description provided for @conflictingBookingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Недоступные даты брони:'**
  String get conflictingBookingsTitle;

  /// No description provided for @bookingActive.
  ///
  /// In ru, this message translates to:
  /// **'Активна'**
  String get bookingActive;

  /// No description provided for @bookingCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменена'**
  String get bookingCancelled;

  /// No description provided for @buttonCheck.
  ///
  /// In ru, this message translates to:
  /// **'Проверить'**
  String get buttonCheck;

  /// No description provided for @buttonBook.
  ///
  /// In ru, this message translates to:
  /// **'Забронировать'**
  String get buttonBook;

  /// No description provided for @buttonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get buttonCancel;

  /// No description provided for @bookingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Брони номера'**
  String get bookingsTitle;

  /// No description provided for @windowsOverviewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отели (Windows Widget)'**
  String get windowsOverviewTitle;

  /// No description provided for @windowsOverviewEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных по отелям'**
  String get windowsOverviewEmpty;

  /// No description provided for @buttonRefresh.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get buttonRefresh;

  /// No description provided for @filtersMinPrice.
  ///
  /// In ru, this message translates to:
  /// **'Мин. цена'**
  String get filtersMinPrice;

  /// No description provided for @filtersMaxPrice.
  ///
  /// In ru, this message translates to:
  /// **'Макс. цена'**
  String get filtersMaxPrice;

  /// No description provided for @filtersRoomType.
  ///
  /// In ru, this message translates to:
  /// **'Тип номера'**
  String get filtersRoomType;

  /// No description provided for @filtersAnyType.
  ///
  /// In ru, this message translates to:
  /// **'Любой'**
  String get filtersAnyType;

  /// No description provided for @filtersDates.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать даты брони'**
  String get filtersDates;

  /// No description provided for @filtersApply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get filtersApply;

  /// No description provided for @errorLoading.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки'**
  String get errorLoading;

  /// No description provided for @statusFreeToday.
  ///
  /// In ru, this message translates to:
  /// **'Свободно сегодня'**
  String get statusFreeToday;

  /// No description provided for @statusBusyToday.
  ///
  /// In ru, this message translates to:
  /// **'Занято сегодня'**
  String get statusBusyToday;

  /// No description provided for @statusNextBookingTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшая бронь: завтра'**
  String get statusNextBookingTomorrow;

  /// No description provided for @statusNextBookingDays.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшая бронь: через {days} дн.'**
  String statusNextBookingDays(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
