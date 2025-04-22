/*
  profile_screen.dart
  April 1, 2025
  Grace Bergquist
  Allows users to view and edit their profile based on the UserProfile model.

  Editable: name, age, major, isTutor
  Read-only: email, school domain

  Uses: Riverpod UserProfileNotifier for Firestore sync
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemo/providers/user_profile_provider.dart';
import 'package:gemo/constants/majors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController majorController = TextEditingController();

  final TextEditingController bioController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  String? selectedMajor;
  bool isTutor = false;
  List<String> selectedSubjects = [];
  List<String> availableDays = [];
  String? educationLevel;

  bool _initialized = false;
  bool _isAutoScrolling = false;

  final List<String> subjectsList = [
    'Mathematics', 'Physics', 'Chemistry', 'Biology',
    'Computer Science', 'Literature', 'History', 'Geography',
    'Economics', 'Psychology', 'Foreign Languages'
  ];

  final List<String> daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  final List<String> educationLevels = [
    'Undergraduate', 'Bachelor\'s Degree',
    'Master\'s Degree', 'Ph.D.', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0 &&
        !_isAutoScrolling) {
      HapticFeedback.lightImpact();
    }
  }

  void _scrollToPosition(double position) {
    if (_scrollController.hasClients) {
      setState(() => _isAutoScrolling = true);
      _scrollController
          .animateTo(position,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut)
          .then((_) => setState(() => _isAutoScrolling = false));
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollToPosition(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    nameController.dispose();
    ageController.dispose();
    majorController.dispose();
    bioController.dispose();
    experienceController.dispose();
    rateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileChanges(String uid) async {
    Map<String, dynamic>? tutorProfileData;

    if (isTutor) {
      tutorProfileData = {
        'bio': bioController.text.trim(),
        'yearsExperience': int.tryParse(experienceController.text.trim()),
        'subjects': selectedSubjects,
        'availableDays': availableDays,
        'educationLevel': educationLevel,
      };
    }

    await ref.read(userProfileNotifierProvider(uid).notifier).updateProfile(
          name: nameController.text.trim(),
          age: int.tryParse(ageController.text.trim()),
          major: selectedMajor,
          isTutor: isTutor,
          tutorProfile: tutorProfileData,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("No user is logged in.")),
      );
    }

    final profileAsync = ref.watch(userProfileNotifierProvider(uid));

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text("Error loading profile: $e")),
      ),
      data: (profile) {
        if (!_initialized) {
          nameController.text = profile.name;
          ageController.text = profile.age?.toString() ?? '';
          majorController.text = profile.major ?? '';
          selectedMajor =
              majorsList.contains(profile.major) ? profile.major : null;
          isTutor = profile.isTutor ?? false;

          if (profile.tutorProfile != null) {
            bioController.text = profile.tutorProfile?.bio ?? '';
            experienceController.text =
                profile.tutorProfile?.yearsExperience?.toString() ?? '';
            selectedSubjects =
                profile.tutorProfile?.subjects?.toList() ?? [];
            availableDays =
                profile.tutorProfile?.availableDays?.toList() ?? [];
            educationLevel = profile.tutorProfile?.educationLevel;
          }

          _initialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('Profile'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () => _scrollToPosition(0),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildProfileField('Name', nameController),
                _buildProfileField('Age', ageController,
                    keyboardType: TextInputType.number),
                _buildDropdownField('Major', majorsList, selectedMajor,
                    (newValue) {
                  setState(() {
                    selectedMajor = newValue;
                    majorController.text = newValue ?? '';
                  });
                }),
                _buildSwitchField(
                  label: 'Enable Tutoring Profile',
                  value: isTutor,
                  onChanged: (val) {
                    setState(() => isTutor = val);
                    if (val) {
                      Future.delayed(const Duration(milliseconds: 100),
                          _scrollToBottom);
                    }
                  },
                ),
                if (isTutor) ...[
                  const Divider(thickness: 1),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Tutoring Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildProfileField(
                    'Bio (describe your tutoring approach)',
                    bioController,
                    maxLines: 3,
                  ),
                  _buildDropdownField('Education Level', educationLevels,
                      educationLevel, (newValue) {
                    setState(() => educationLevel = newValue);
                  }),
                  _buildProfileField(
                    'Years of Experience',
                    experienceController,
                    keyboardType: TextInputType.number,
                  ),
                  _buildChipSelectionField('Subjects I Can Tutor',
                      subjectsList, selectedSubjects),
                  _buildCheckboxListField(
                      'Available Days', daysOfWeek, availableDays),
                ],
                _buildReadOnlyField('Email', profile.email),
                _buildReadOnlyField('School Domain', profile.schoolDomain),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _saveProfileChanges(uid),
                  child: const Text('Save'),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          floatingActionButton: isTutor
              ? FloatingActionButton(
                  mini: true,
                  onPressed: _scrollToBottom,
                  child: const Icon(Icons.arrow_downward),
                  tooltip: 'Scroll to bottom',
                )
              : null,
        );
      },
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value,
      void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            items: items
                .map((item) =>
                    DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade100,
            ),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSelectionField(
      String label, List<String> options, List<String> selectedOptions) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedOptions.add(option);
                    } else {
                      selectedOptions.remove(option);
                    }
                  });
                },
                backgroundColor: Colors.grey.shade200,
                selectedColor: Colors.blue.shade100,
                checkmarkColor: Colors.blue,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxListField(
      String label, List<String> options, List<String> selectedOptions) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: options.map((option) {
                return CheckboxListTile(
                  title: Text(option),
                  value: selectedOptions.contains(option),
                  onChanged: (selected) {
                    setState(() {
                      if (selected ?? false) {
                        selectedOptions.add(option);
                      } else {
                        selectedOptions.remove(option);
                      }
                    });
                  },
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
