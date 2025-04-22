class TutorProfile {
  final String? bio;
  final int? yearsExperience;
  final List<String>? subjects;
  final List<String>? availableDays;
  final String? educationLevel;

  TutorProfile({
    this.bio,
    this.yearsExperience,
    this.subjects,
    this.availableDays,
    this.educationLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'bio': bio,
      'yearsExperience': yearsExperience,
      'subjects': subjects,
      'availableDays': availableDays,
      'educationLevel': educationLevel,
    };
  }

  factory TutorProfile.fromMap(Map<String, dynamic> map) {
    return TutorProfile(
      bio: map['bio'],
      yearsExperience: map['yearsExperience'],
      subjects: List<String>.from(map['subjects'] ?? []),
      availableDays: List<String>.from(map['availableDays'] ?? []),
      educationLevel: map['educationLevel'],
    );
  }
}