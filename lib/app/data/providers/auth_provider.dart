import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/master_admin_model.dart';

class AppAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Secure sign in via Firebase Authentication
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Authenticate directly against masterAdmin collection (created by the Admin App)
  Future<MasterAdminModel?> authenticateMasterAdmin({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();

    // 1. Try finding doc by ID (e.g. masterAdmin/piyush)
    var doc = await _firestore.collection('masterAdmin').doc(cleanUsername).get();

    // 2. If not found by docId, search by 'username' field
    if (!doc.exists || doc.data() == null) {
      final query = await _firestore
          .collection('masterAdmin')
          .where('username', isEqualTo: cleanUsername)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        doc = query.docs.first;
      }
    }

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;
    final storedPass = data['pass']?.toString() ?? data['password']?.toString();
    if (storedPass == null || storedPass != password) {
      throw Exception('INVALID_PASSWORD');
    }

    return MasterAdminModel.fromFirestore(doc);
  }

  /// Retrieve the trusted Master Admin profile for the authenticated UID
  Future<MasterAdminModel?> fetchMasterAdminProfile(String uid) async {
    final doc = await _firestore.collection('masterAdmin').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return MasterAdminModel.fromFirestore(doc);
  }
}
