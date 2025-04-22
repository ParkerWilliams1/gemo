import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/providers/user_profile_notifier.dart';
import '../models/user_profile.dart';

/// 1. UID-aware StateNotifierProvider using `.family`
final userProfileNotifierProvider = StateNotifierProvider.family<
    UserProfileNotifier, AsyncValue<UserProfile>, String>((ref, uid) {
  return UserProfileNotifier(uid);
});

/// 2. Optional helper to watch current user's profile reactively
final currentUserProfileProvider = Provider<AsyncValue<UserProfile>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const AsyncValue.loading();
  return ref.watch(userProfileNotifierProvider(user.uid));
});

/// 3. Optional basic profile fetcher (non-notifier, if needed elsewhere)
final userProfileProvider = FutureProvider.family<UserProfile, String>((ref, uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (!doc.exists) {
    throw Exception("User profile does not exist.");
  }
  return UserProfile.fromMap(doc.data()!);
});
