import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to handle trusted time and duration calculations (3 days demo, 30 days production)
class TimeService {
  /// Current server-aligned UTC time
  DateTime get currentServerTime {
    return DateTime.now().toUtc();
  }

  /// Calculates the 3-day demo start and end timestamps
  Map<String, Timestamp> calculateDemoTimestamps({DateTime? baseTime}) {
    final start = (baseTime ?? currentServerTime).toUtc();
    final end = start.add(const Duration(days: 3));
    return {
      'demoStartAt': Timestamp.fromDate(start),
      'demoEndAt': Timestamp.fromDate(end),
    };
  }

  /// Calculates the 30-day production start and end timestamps
  Map<String, Timestamp> calculateProductionTimestamps({DateTime? baseTime}) {
    final start = (baseTime ?? currentServerTime).toUtc();
    final end = start.add(const Duration(days: 30));
    return {
      'productionStartAt': Timestamp.fromDate(start),
      'productionEndAt': Timestamp.fromDate(end),
    };
  }
}
