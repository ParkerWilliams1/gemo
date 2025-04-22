import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  UserProfileNotifier() : super(const AsyncLoading()) {
    _loadUserProfile();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) throw Exception("User profile not found");

      state = AsyncValue.data(UserProfile.fromMap(doc.data()!));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update user profile including tutorProfile fields
  Future<void> updateProfile({
    String? name,
    int? age,
    String? major,
    bool? isTutor,
    Map<String, dynamic>? tutorProfile,
  }) async {
    final user = _auth.currentUser;
    if (user == null || state is! AsyncData) return;

    final currentProfile = (state as AsyncData<UserProfile>).value;

    final updatedMap = {
      'name': name ?? currentProfile.name,
      'age': age ?? currentProfile.age,
      'major': major ?? currentProfile.major,
      'isTutor': isTutor ?? currentProfile.isTutor,
      if (isTutor == true && tutorProfile != null)
        'tutorProfile': tutorProfile,
      if (isTutor == false)
        'tutorProfile': FieldValue.delete(),
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(updatedMap, SetOptions(merge: true));

    await refreshProfile();
  }

  /// Reload the profile from Firestore safely
  Future<void> refreshProfile() async {
    try {
      state = const AsyncLoading();
      await _loadUserProfile();
    } catch (e, st) {
      print("Error refreshing profile: $e");
      state = AsyncValue.error(e, st);
    }
  }
}