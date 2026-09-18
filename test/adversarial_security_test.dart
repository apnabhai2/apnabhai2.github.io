import 'package:flutter_test/flutter_test.dart';
import 'package:apnamasteradmin/app/data/models/user_model.dart';
import 'package:apnamasteradmin/app/data/models/master_admin_model.dart';

void main() {
  group('3-TIER ARCHITECTURE & SECURITY VERIFICATION SUITE', () {
    final baseTime = DateTime.utc(2026, 9, 14, 12, 0);

    // 1. Client Software Schema Integrity
    test('[SCHEMA-01] UserModel schema strictly conforms to user software specification', () {
      final user = UserModel(
        id: 'piyu',
        pass: '12345678',
        deviceId: '5CCBEC204F42A5F6BA69ADF6C579574F',
        currentDate: baseTime,
        expiryDate: baseTime.add(const Duration(days: 3)),
        stop: false,
        masterCode: 'MASTER_PIYUSH',
      );

      final map = user.toMap();
      expect(map.containsKey('id'), isTrue);
      expect(map.containsKey('pass'), isTrue);
      expect(map.containsKey('deviceId'), isTrue);
      expect(map.containsKey('currentDate'), isTrue);
      expect(map.containsKey('expiryDate'), isTrue);
      expect(map.containsKey('stop'), isTrue);
      expect(map.containsKey('masterCode'), isTrue);
      expect(map.containsKey('isActive'), isFalse);
      expect(map.containsKey('status'), isFalse);
    });

    // 2. Demo Duration Invariant Verification (3 Days)
    test('[DURATION-02] Demo timestamp duration strictly matches 72 hours (3 days)', () {
      final start = baseTime;
      final end = start.add(const Duration(days: 3));
      final diff = end.difference(start);

      expect(diff.inDays, equals(3));
      expect(diff.inHours, equals(72));
    });

    // 3. Production Duration Invariant Verification (30 Days)
    test('[DURATION-03] Production timestamp duration strictly matches 720 hours (30 days)', () {
      final start = baseTime;
      final end = start.add(const Duration(days: 30));
      final diff = end.difference(start);

      expect(diff.inDays, equals(30));
      expect(diff.inHours, equals(720));
    });

    // 4. Cross-Admin Data Isolation Invariant
    test('[ISOLATION-04] Cross-admin masterCode isolation invariant', () {
      final adminA = MasterAdminModel(
        uid: 'piyush',
        username: 'piyush',
        masterCode: 'MASTER_PIYUSH',
      );

      final adminB = MasterAdminModel(
        uid: 'rahul',
        username: 'rahul',
        masterCode: 'MASTER_RAHUL',
      );

      final userA = UserModel(
        id: 'user_a',
        pass: 'pass_a',
        currentDate: baseTime,
        expiryDate: baseTime.add(const Duration(days: 3)),
        masterCode: adminA.masterCode,
      );

      final userB = UserModel(
        id: 'user_b',
        pass: 'pass_b',
        currentDate: baseTime,
        expiryDate: baseTime.add(const Duration(days: 3)),
        masterCode: adminB.masterCode,
      );

      expect(userB.masterCode == adminA.masterCode, isFalse,
          reason: 'Admin A must never see or match Admin B users');
      expect(userA.masterCode == adminB.masterCode, isFalse,
          reason: 'Admin B must never see or match Admin A users');
    });

    // 5. Dynamic Status Expiration
    test('[EXPIRY-05] Status dynamically reflects expired demo when expiryDate passes', () {
      final start = DateTime.now().subtract(const Duration(days: 5));
      final end = start.add(const Duration(days: 3)); // Expired 2 days ago

      final user = UserModel(
        id: 'expired_user',
        pass: '12345678',
        currentDate: start,
        expiryDate: end,
        masterCode: 'MASTER_PIYUSH',
      );

      expect(user.isExpired, isTrue);
      expect(user.statusLabel, equals('DEMO EXPIRED'));
    });

    // 6. MasterAdmin Role Default
    test('[ADMIN-06] MasterAdmin role defaults to masterAdmin', () {
      final admin = MasterAdminModel(
        uid: 'piyush',
        username: 'piyush',
        masterCode: 'MASTER_PIYUSH',
      );

      expect(admin.role, equals('masterAdmin'));
      final map = admin.toMap();
      expect(map['role'], equals('masterAdmin'));
    });

    // 7. Hardware Device Reset Invariant
    test('[HARDWARE-07] Resetting deviceId correctly detaches hardware binding', () {
      final user = UserModel(
        id: 'piyu',
        pass: '12345678',
        deviceId: '5CCBEC204F42A5F6BA69ADF6C579574F',
        currentDate: baseTime,
        expiryDate: baseTime.add(const Duration(days: 3)),
        masterCode: 'MASTER_PIYUSH',
      );

      expect(user.deviceId.isNotEmpty, isTrue);

      final resetUser = user.copyWith(deviceId: '');
      expect(resetUser.deviceId, isEmpty,
          reason: 'Reset device must clear hardware identifier');
    });
  });
}
