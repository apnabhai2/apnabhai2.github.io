import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Real-time stream of users scoped strictly to the provided masterCode
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUsersByMasterCode(
      String masterCode) {
    return _usersRef
        .where('masterCode', isEqualTo: masterCode)
        .snapshots();
  }

  /// Set or create a user document using the user id as document ID
  Future<void> setUser(String userId, Map<String, dynamic> data) async {
    await _usersRef.doc(userId).set(data);
  }

  /// Create a new user document in Firestore with auto-generated ID
  Future<DocumentReference<Map<String, dynamic>>> createUser(
      Map<String, dynamic> data) async {
    return await _usersRef.add(data);
  }

  /// Update an existing user document
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _usersRef.doc(userId).update(data);
  }

  /// Delete a user document
  Future<void> deleteUser(String userId) async {
    await _usersRef.doc(userId).delete();
  }

  /// Fetch single user
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String userId) async {
    return await _usersRef.doc(userId).get();
  }
}
