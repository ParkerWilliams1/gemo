import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/providers/user_profile_notifier.dart';
import '../models/user_profile.dart';

final userProfileNotifierProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>(
  (ref) => UserProfileNotifier(),
);

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("No user signed in.");
  }

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  if (!doc.exists) {
    throw Exception("User profile does not exist.");
  }

  return UserProfile.fromMap(doc.data()!);
});