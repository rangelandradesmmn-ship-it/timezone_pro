import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TimezoneService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (!_initialized) {
      tz.initializeTimeZones();
      _initialized = true;
    }
  }

  static tz.TZDateTime getCurrentTimeForZone(String timezoneName) {
    final location = tz.getLocation(timezoneName);
    return tz.TZDateTime.now(location);
  }

  static tz.TZDateTime getConvertedTime(DateTime referenceTime, String fromTimezone, String toTimezone) {
    final fromLocation = tz.getLocation(fromTimezone);
    final toLocation = tz.getLocation(toTimezone);

    final tzReferenceTime = tz.TZDateTime(
      fromLocation,
      referenceTime.year,
      referenceTime.month,
      referenceTime.day,
      referenceTime.hour,
      referenceTime.minute,
      referenceTime.second,
    );

    return tz.TZDateTime.from(tzReferenceTime, toLocation);
  }

  static String formatOffset(Duration offset) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String sign = offset.isNegative ? '-' : '+';
    int hours = offset.inHours.abs();
    int minutes = offset.inMinutes.remainder(60).abs();
    if (minutes == 0) {
      return 'UTC$sign$hours';
    }
    return 'UTC$sign$hours:${twoDigits(minutes)}';
  }
}
