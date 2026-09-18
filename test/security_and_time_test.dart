import 'package:flutter_test/flutter_test.dart';
import 'package:apnamasteradmin/app/data/services/time_service.dart';
import 'package:apnamasteradmin/app/data/models/master_admin_model.dart';

void main() {
  group('TimeService & Duration Tests', () {
    final timeService = TimeService();
    final fixedTime = DateTime.utc(2026, 9, 15, 19, 0);

    test('Demo timestamps calculate exactly 3 days', () {
      final timestamps = timeService.calculateDemoTimestamps(baseTime: fixedTime);
      final start = timestamps['demoStartAt']!.toDate();
      final end = timestamps['demoEndAt']!.toDate();

      expect(end.difference(start).inDays, equals(3));
      expect(end.difference(start).inHours, equals(72));
    });

    test('Production timestamps calculate exactly 30 days', () {
      final timestamps = timeService.calculateProductionTimestamps(baseTime: fixedTime);
      final start = timestamps['productionStartAt']!.toDate();
      final end = timestamps['productionEndAt']!.toDate();

      expect(end.difference(start).inDays, equals(30));
      expect(end.difference(start).inHours, equals(720));
    });
  });

  group('MasterAdminModel Tests', () {
    test('MasterAdminModel serialization and copyWith', () {
      final admin = MasterAdminModel(
        uid: 'admin_uid_123',
        username: 'admin1',
        masterCode: 'MASTER001',
        email: 'admin1@masteradmin.com',
      );

      expect(admin.uid, equals('admin_uid_123'));
      expect(admin.username, equals('admin1'));
      expect(admin.masterCode, equals('MASTER001'));
      expect(admin.role, equals('masterAdmin'));

      final updated = admin.copyWith(masterCode: 'MASTER002');
      expect(updated.masterCode, equals('MASTER002'));
      expect(updated.username, equals('admin1'));
    });
  });
}
