import 'package:flutter_test/flutter_test.dart';
import 'package:apnamasteradmin/app/data/models/user_model.dart';

void main() {
  group('UserModel 3-Tier Software Schema Tests', () {
    final baseTime = DateTime(2026, 9, 14, 12, 28, 4);

    test('User serialization matches client software requirements without isActive or status', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'piyu',
        pass: '12345678',
        deviceId: '5CCBEC204F42A5F6BA69ADF6C579574F',
        currentDate: now,
        expiryDate: now.add(const Duration(days: 3)),
        stop: false,
        masterCode: 'MASTER_PIYUSH',
      );

      expect(user.id, equals('piyu'));
      expect(user.pass, equals('12345678'));
      expect(user.deviceId, equals('5CCBEC204F42A5F6BA69ADF6C579574F'));
      expect(user.stop, isFalse);
      expect(user.isDemo, isTrue);
      expect(user.statusLabel, equals('DEMO'));
      expect(user.masterCode, equals('MASTER_PIYUSH'));

      final map = user.toMap();
      expect(map['id'], equals('piyu'));
      expect(map['pass'], equals('12345678'));
      expect(map['deviceId'], equals('5CCBEC204F42A5F6BA69ADF6C579574F'));
      expect(map['stop'], isFalse);
      expect(map['masterCode'], equals('MASTER_PIYUSH'));
      // Verify isActive and status are strictly NOT present in map
      expect(map.containsKey('isActive'), isFalse);
      expect(map.containsKey('status'), isFalse);
    });

    test('Production user with 30-day expiry evaluates correctly', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'piyu',
        pass: '12345678',
        deviceId: '5CCBEC204F42A5F6BA69ADF6C579574F',
        currentDate: now,
        expiryDate: now.add(const Duration(days: 30)),
        masterCode: 'MASTER_PIYUSH',
      );

      expect(user.isExpired, isFalse);
      expect(user.isProduction, isTrue);
      expect(user.isDemo, isFalse);
      expect(user.statusLabel, equals('PRODUCTION'));
    });

    test('Expired demo license detection works reliably', () {
      final expiredUser = UserModel(
        id: 'expired_user',
        pass: 'pass123',
        currentDate: DateTime.now().subtract(const Duration(days: 5)),
        expiryDate: DateTime.now().subtract(const Duration(days: 2)),
        masterCode: 'MASTER_PIYUSH',
      );

      expect(expiredUser.isExpired, isTrue);
      expect(expiredUser.isDemo, isTrue);
      expect(expiredUser.statusLabel, equals('DEMO EXPIRED'));
      expect(expiredUser.remainingTimeFormatted, equals('Expired'));
    });

    test('Date formatting matches standard dd/MM/yyyy h:mm a', () {
      final user = UserModel(
        id: 'piyu',
        pass: '123',
        currentDate: DateTime(2026, 9, 14, 12, 28),
        expiryDate: DateTime(2026, 10, 14, 12, 28),
        masterCode: 'MASTER_PIYUSH',
      );

      expect(user.formattedCurrentDate, equals('14/09/2026 12:28 PM'));
      expect(user.formattedExpiryDate, equals('14/10/2026 12:28 PM'));
    });

    test('Stop flag serialization, parsing, and statusLabel evaluation', () {
      final defaultUser = UserModel(
        id: 'piyu',
        pass: '12345678',
        currentDate: baseTime,
        expiryDate: baseTime.add(const Duration(days: 3)),
        masterCode: 'MASTER_PIYUSH',
      );
      expect(defaultUser.stop, isFalse);
      expect(defaultUser.toMap()['stop'], isFalse);

      final stoppedUser = defaultUser.copyWith(stop: true);
      expect(stoppedUser.stop, isTrue);
      expect(stoppedUser.toMap()['stop'], isTrue);
      expect(stoppedUser.statusLabel, equals('STOPPED'));

      // fromMap parsing tests
      final parsedFromBool = UserModel.fromMap({'stop': true, 'id': 'u1', 'pass': 'p'}, 'u1');
      expect(parsedFromBool.stop, isTrue);

      final parsedFromString = UserModel.fromMap({'stop': 'true', 'id': 'u2', 'pass': 'p'}, 'u2');
      expect(parsedFromString.stop, isTrue);

      final parsedFromNumber = UserModel.fromMap({'stop': 1, 'id': 'u3', 'pass': 'p'}, 'u3');
      expect(parsedFromNumber.stop, isTrue);

      final parsedFromFalse = UserModel.fromMap({'stop': false, 'id': 'u4', 'pass': 'p'}, 'u4');
      expect(parsedFromFalse.stop, isFalse);
    });
  });
}
