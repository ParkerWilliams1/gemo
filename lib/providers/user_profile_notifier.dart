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

  /// Update a specific field or set of fields in Firestore and local state
  Future<void> updateProfile(
      {String? name, int? age, String? major, bool? isTutor}) async {
    final user = _auth.currentUser;
    if (user == null || state is! AsyncData) return;

    final currentProfile = (state as AsyncData<UserProfile>).value;

    final updatedProfile = UserProfile(
      uid: currentProfile.uid,
      name: name ?? currentProfile.name,
      age: age ?? currentProfile.age,
      email: currentProfile.email,
      schoolDomain: currentProfile.schoolDomain,
      createdAt: currentProfile.createdAt,
      major: major ?? currentProfile.major, // use new major
      isTutor: isTutor ?? currentProfile.isTutor, // use new isTutor
    );

    // Update Firestore
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(updatedProfile.toMap());

    // Update local state
    state = AsyncValue.data(updatedProfile);
  }

  /// Refresh the profile manually
  Future<void> refreshProfile() async {
    state = const AsyncLoading();
    await _loadUserProfile();
  }
}
