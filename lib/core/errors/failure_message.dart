import 'package:hotel_booking_app/core/errors/failure.dart';

String failureMessage(Object error) {
  if (error case final Failure failure) {
    return failure.message;
  }
  return 'Произошла непредвиденная ошибка. Попробуйте ещё раз.';
}
