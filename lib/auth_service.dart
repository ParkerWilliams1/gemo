import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();

        // Ensure Firestore user document is created at signup
        await _firestore.collection('users').doc(user.uid).set({
          "uid": user.uid.toString(), // 🔹 Ensure it's always a string
          "email": email,
          "matchable": true,
          "currentChat": null,
          "schoolDomain": email.split('@').last,
          "createdAt": FieldValue.serverTimestamp()
        });
      }

      return null; // No error
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        return "Please verify your email before signing in.";
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('chat_queue')
          .doc(currentUser.uid)
          .delete()
          .catchError((e) {
        Logger("ℹ️ No queue entry to delete on sign-out.");
      });
    }

    await _auth.signOut();
  }
}
