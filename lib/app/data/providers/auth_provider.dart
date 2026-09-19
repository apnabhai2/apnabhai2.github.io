import 'dart:convert';
import 'package:crypto/crypto.dart';
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

  /// Sign out from Firebase Authentication
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Authenticate Master Admin:
  /// 1. Supports Firebase Auth (Email & Password)
  /// 2. Supports Username lookup with Firebase Auth resolution
  /// 3. Backwards compatible with legacy accounts
  Future<MasterAdminModel?> authenticateMasterAdmin({
    required String usernameOrEmail,
    required String password,
  }) async {
    final cleanInput = usernameOrEmail.trim();
    DocumentSnapshot? adminDoc;

    if (cleanInput.contains('@')) {
      // Input is an Email address -> Authenticate directly with Firebase Auth
      final credential = await _signInWithFirebaseAuth(cleanInput, password);
      final uid = credential.user?.uid;

      if (uid != null) {
        final query = await _firestore
            .collection('masterAdmin')
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          adminDoc = query.docs.first;
        }
      }

      if (adminDoc == null) {
        final query = await _firestore
            .collection('masterAdmin')
            .where('email', isEqualTo: cleanInput)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          adminDoc = query.docs.first;
        }
      }
    } else {
      // Input is a Username -> Lookup document first
      var doc = await _firestore.collection('masterAdmin').doc(cleanInput).get();
      if (!doc.exists || doc.data() == null) {
        final query = await _firestore
            .collection('masterAdmin')
            .where('username', isEqualTo: cleanInput)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          doc = query.docs.first;
        }
      }

      if (!doc.exists || doc.data() == null) {
        throw Exception('USER_NOT_FOUND');
      }

      adminDoc = doc;
      final data = doc.data() as Map<String, dynamic>;
      final registeredEmail = data['email'] as String?;

      if (registeredEmail != null && registeredEmail.isNotEmpty) {
        // Master admin was created via Firebase Auth in Apna Admin!
        await _signInWithFirebaseAuth(registeredEmail, password);
      } else {
        // Legacy fallback: verify password/hash directly
        final storedPass = data['pass']?.toString() ?? data['password']?.toString();
        final passwordHash = _hashPassword(password);
        final isMatch = (storedPass == password || storedPass == passwordHash);
        if (!isMatch) {
          throw Exception('INVALID_PASSWORD');
        }

        // Auto-upgrade plain text to SHA-256 hash in Firestore
        if (storedPass == password && storedPass != passwordHash) {
          try {
            await doc.reference.update({
              'pass': passwordHash,
              'isHashed': true,
            });
          } catch (_) {}
        }
      }
    }

    if (adminDoc == null || !adminDoc.exists || adminDoc.data() == null) {
      return null;
    }

    return MasterAdminModel.fromFirestore(adminDoc);
  }

  Future<UserCredential> _signInWithFirebaseAuth(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('INVALID_PASSWORD');
      } else if (e.code == 'user-not-found') {
        throw Exception('USER_NOT_FOUND');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email format.');
      }
      throw Exception(e.message ?? 'Authentication failed.');
    }
  }

  /// Secure SHA-256 password hashing for legacy accounts
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Retrieve the trusted Master Admin profile for the authenticated UID
  Future<MasterAdminModel?> fetchMasterAdminProfile(String uid) async {
    final query = await _firestore
        .collection('masterAdmin')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return MasterAdminModel.fromFirestore(query.docs.first);
    }

    final doc = await _firestore.collection('masterAdmin').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return MasterAdminModel.fromFirestore(doc);
    }
    return null;
  }
}
