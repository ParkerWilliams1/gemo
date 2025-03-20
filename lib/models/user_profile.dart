import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String schoolDomain;
  final bool matchable;
  final String? currentChat;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.schoolDomain,
    required this.matchable,
    this.currentChat,
    required this.createdAt,
  });

  /// Convert Firestore document to a UserProfile object
  factory UserProfile.fromFirestore(Map<String, dynamic> data, String docId) {
    return UserProfile(
      uid: docId,
      email: data['email'] ?? '',
      schoolDomain: data['schoolDomain'] ?? '',
      matchable: data['matchable'] ?? false,
      currentChat: data['currentChat'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert UserProfile object to a Map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'schoolDomain': schoolDomain,
      'matchable': matchable,
      'currentChat': currentChat,
      'createdAt': createdAt,
    };
  }
}
