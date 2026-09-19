import 'package:cloud_firestore/cloud_firestore.dart';

class MasterAdminModel {
  final String uid;
  final String username;
  final String masterCode;
  final String? email;
  final DateTime? createdAt;
  final String role;

  MasterAdminModel({
    required this.uid,
    required this.username,
    required this.masterCode,
    this.email,
    this.createdAt,
    this.role = 'masterAdmin',
  });

  factory MasterAdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MasterAdminModel(
      uid: doc.id,
      username: data['username'] as String? ?? '',
      masterCode: data['masterCode'] as String? ?? '',
      email: data['email'] as String?,
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      role: data['role'] as String? ?? 'masterAdmin',
    );
  }

  factory MasterAdminModel.fromMap(Map<String, dynamic> map, String id) {
    return MasterAdminModel(
      uid: id,
      username: map['username'] as String? ?? '',
      masterCode: map['masterCode'] as String? ?? '',
      email: map['email'] as String?,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null),
      role: map['role'] as String? ?? 'masterAdmin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'masterCode': masterCode,
      if (email != null) 'email': email,
      'role': role,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'masterCode': masterCode,
      if (email != null) 'email': email,
      'role': role,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  MasterAdminModel copyWith({
    String? uid,
    String? username,
    String? masterCode,
    String? email,
    DateTime? createdAt,
    String? role,
  }) {
    return MasterAdminModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      masterCode: masterCode ?? this.masterCode,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }
}
