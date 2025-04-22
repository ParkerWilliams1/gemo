import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserProfileNotifier(this.uid) : super(const AsyncLoading()) {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) throw Exception("User profile not found");

      state = AsyncValue.data(UserProfile.fromMap(doc.data()!));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    String? name,
    int? age,
    String? major,
    bool? isTutor,
    Map<String, dynamic>? tutorProfile,
  }) async {
    if (state is! AsyncData) return;

    final currentProfile = (state as AsyncData<UserProfile>).value;

    final updatedProfile = UserProfile(
      uid: currentProfile.uid,
      name: name ?? currentProfile.name,
      age: age ?? currentProfile.age,
      email: currentProfile.email,
      schoolDomain: currentProfile.schoolDomain,
      createdAt: currentProfile.createdAt,
      major: major ?? currentProfile.major,
      isTutor: isTutor ?? currentProfile.isTutor,
      tutorProfile: tutorProfile, // optional if your model supports it
    );

    await _firestore.collection('users').doc(uid).update(updatedProfile.toMap());
    state = AsyncValue.data(updatedProfile);
  }

  Future<void> refreshProfile() async {
    state = const AsyncLoading();
    await _loadUserProfile();
  }
}
