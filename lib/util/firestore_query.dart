import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class FirestoreQuery {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch a specific user's profile by UID
  Future<UserProfile?> fetchUserProfileByUid(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("users").doc(uid).get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>;
        return UserProfile.fromFirestore(data, doc.id); // ✅ Use correct method
      } else {
        print("User profile not found for UID: $uid");
        return null;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  /// Fetch the currently logged-in user's profile
  Future<UserProfile?> fetchCurrentUserProfile() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        print("No user is currently logged in.");
        return null;
      }

      return await fetchUserProfileByUid(currentUser.uid);
    } catch (e) {
      print("Error fetching current user profile: $e");
      return null;
    }
  }
}
