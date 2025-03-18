import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await userCredential.user?.sendEmailVerification();
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
    await _auth.signOut();
  }

  Future<String?> getCurrentUserEmail() async {
    User? user = _auth.currentUser;
    return user?.email;
  }
}
