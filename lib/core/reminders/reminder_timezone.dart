import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

abstract final class ReminderTimezone {
  static bool _configured = false;

  static Future<void> ensureConfigured() async {
    if (_configured) return;

    tz_data.initializeTimeZones();
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone.identifier));
      _configured = true;
      if (kDebugMode) {
        debugPrint('Hydra timezone: ${timeZone.identifier}');
      }
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
      _configured = true;
      if (kDebugMode) {
        debugPrint('Hydra timezone fallback UTC: $e');
      }
    }
  }
}
