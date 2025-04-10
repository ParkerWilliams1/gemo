import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final int? age;
  final String email;
  final String schoolDomain;
  final DateTime createdAt;
  final String? major;
  final bool? isTutor;

  var tutorProfile;

  UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    required this.email,
    required this.schoolDomain,
    required this.createdAt,
    required this.major,
    required this.isTutor,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'email': email,
      'schoolDomain': schoolDomain,
      'createdAt': createdAt,
      'major': major,
      'isTutor': isTutor,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      age: map['age'],
      email: map['email'] ?? '',
      schoolDomain: map['schoolDomain'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      major: map['major'] ?? '',
      isTutor: map['tutor'] ?? false,
    );
  }
}
