import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/models/user.dart' as models;

class AuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<models.User?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid == null) return null;
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return models.User.fromMap(doc.id, doc.data()!);
    } catch (e, st) {
      // Log details to help diagnose platform/channel issues (Pigeon cast errors)
      // These prints will appear in the device logs and in the flutter run console.
      // Keep the original behavior by rethrowing after logging.
      // ignore: avoid_print
      print('AuthService.signIn ERROR: ${e.runtimeType} -> $e');
      // ignore: avoid_print
      print(st);
      rethrow;
    }
  }

  Future<models.User?> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid == null) return null;
      final data = {
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _db.collection('users').doc(uid).set(data);
      final doc = await _db.collection('users').doc(uid).get();
      return models.User.fromMap(doc.id, doc.data()!);
    } catch (e, st) {
      // Log details for debugging
      // ignore: avoid_print
      print('AuthService.signUp ERROR: ${e.runtimeType} -> $e');
      // ignore: avoid_print
      print(st);
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  models.User? currentUserFromAuth(fb_auth.User? user) {
    if (user == null) return null;
    return models.User(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
    );
  }
}
