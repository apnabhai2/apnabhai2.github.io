import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserModel {
  final String id;
  final String pass;
  final String deviceId;
  final DateTime currentDate;
  final DateTime expiryDate;
  final bool stop; // true if stopped/blocked by admin, false otherwise
  final String masterCode;

  UserModel({
    required this.id,
    required this.pass,
    this.deviceId = '',
    required this.currentDate,
    required this.expiryDate,
    this.stop = false,
    required this.masterCode,
  });

  /// Date formatter conforming to: "14/09/2026 12:28 PM"
  static final DateFormat dateFormatter = DateFormat('dd/MM/yyyy h:mm a');

  /// Total license validity duration in days
  int get licenseDurationDays => expiryDate.difference(currentDate).inDays;

  /// Dynamic check whether the license is a Demo (<= 7 days, default 3 days)
  bool get isDemo => licenseDurationDays <= 7;

  /// Dynamic check whether the license is Production (> 7 days, default 30 days)
  bool get isProduction => !isDemo;

  /// Dynamic check whether the license has expired
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// Human-friendly display status
  String get statusLabel {
    if (stop) {
      return 'STOPPED';
    }
    if (isDemo) {
      return isExpired ? 'DEMO EXPIRED' : 'DEMO';
    }
    if (isProduction) {
      return isExpired ? 'PRODUCTION EXPIRED' : 'PRODUCTION';
    }
    return isExpired ? 'EXPIRED' : 'ACTIVE';
  }

  /// Formatted date strings
  String get formattedCurrentDate => dateFormatter.format(currentDate);
  String get formattedExpiryDate => dateFormatter.format(expiryDate);

  /// Human-friendly remaining time (e.g. "2d 14h left" or "Expired")
  String get remainingTimeFormatted {
    final now = DateTime.now();
    if (now.isAfter(expiryDate)) {
      return 'Expired';
    }
    final diff = expiryDate.difference(now);
    if (diff.inDays > 0) {
      final hours = diff.inHours % 24;
      return '${diff.inDays}d ${hours}h left';
    } else if (diff.inHours > 0) {
      final mins = diff.inMinutes % 60;
      return '${diff.inHours}h ${mins}m left';
    } else {
      return '${diff.inMinutes}m left';
    }
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, doc.id);
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? fallback;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return fallback;
    }

    bool parseStop(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is String) return val.toLowerCase() == 'true' || val == '1';
      if (val is num) return val == 1;
      return false;
    }

    final now = DateTime.now();

    return UserModel(
      id: (map['id'] as String?)?.isNotEmpty == true ? (map['id'] as String) : docId,
      pass: map['pass'] as String? ?? map['password'] as String? ?? '',
      deviceId: map['deviceId'] as String? ?? '',
      currentDate: parseDate(map['currentDate'], now),
      expiryDate: parseDate(map['expiryDate'], now.add(const Duration(days: 3))),
      stop: parseStop(map['stop']),
      masterCode: map['masterCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pass': pass,
      'deviceId': deviceId,
      'currentDate': Timestamp.fromDate(currentDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'stop': stop,
      'masterCode': masterCode,
    };
  }

  UserModel copyWith({
    String? id,
    String? pass,
    String? deviceId,
    DateTime? currentDate,
    DateTime? expiryDate,
    bool? stop,
    String? masterCode,
  }) {
    return UserModel(
      id: id ?? this.id,
      pass: pass ?? this.pass,
      deviceId: deviceId ?? this.deviceId,
      currentDate: currentDate ?? this.currentDate,
      expiryDate: expiryDate ?? this.expiryDate,
      stop: stop ?? this.stop,
      masterCode: masterCode ?? this.masterCode,
    );
  }
}
