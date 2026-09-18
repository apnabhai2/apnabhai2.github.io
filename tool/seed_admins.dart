// Command line tool for initializing Master Admins securely from developer environment.
// This file is NOT included in the web application bundle.
//
// Usage:
//   dart run tool/seed_admins.dart <username> <password> <masterCode>

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apnamasteradmin/firebase_options.dart';

Future<void> main(List<String> args) async {
  if (args.length < 3) {
    // print usage instructions for CLI
    // ignore: avoid_print
    print('Usage: dart run tool/seed_admins.dart <username> <password> <masterCode>');
    return;
  }

  final username = args[0];
  final password = args[1];
  final masterCode = args[2];
  final authEmail = '${username.toLowerCase()}@masteradmin.apnabhai.com';

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  UserCredential credential;
  try {
    credential = await auth.createUserWithEmailAndPassword(
      email: authEmail,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      credential = await auth.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );
    } else {
      rethrow;
    }
  }

  final uid = credential.user!.uid;

  await firestore.collection('masterAdmin').doc(uid).set({
    'username': username,
    'masterCode': masterCode,
    'email': authEmail,
    'role': 'masterAdmin',
    'createdAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  // ignore: avoid_print
  print('Successfully created Master Admin $username with masterCode $masterCode');
}
