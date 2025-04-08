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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemo/providers/user_profile_provider.dart';
import '../providers/user_profile_notifier.dart';
import 'package:gemo/constants/majors.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController majorController = TextEditingController();

  String? selectedMajor;
  bool isTutor = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = ref.read(userProfileNotifierProvider);
    profile.whenData((p) {
      nameController.text = p.name;
      ageController.text = p.age?.toString() ?? '';
      majorController.text = p.major ?? '';
      selectedMajor = majorsList.contains(p.major) ? p.major : null;
      isTutor = p.isTutor ?? false;
    });
  }

  Future<void> _saveProfileChanges() async {
    await ref.read(userProfileNotifierProvider.notifier).updateProfile(
          name: nameController.text.trim(),
          age: int.tryParse(ageController.text.trim()),
          major: selectedMajor,
          isTutor: isTutor,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileNotifierProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text("Error loading profile: $e")),
      ),
      data: (profile) => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildProfileField('Name', nameController),
              _buildProfileField('Age', ageController,
                  keyboardType: TextInputType.number),
              _buildDropdownField('Major', majorsList, selectedMajor, (newValue) {
                setState(() {
                  selectedMajor = newValue;
                  majorController.text = newValue ?? '';
                });
              }),
              _buildSwitchField(
                label: 'Enable Tutoring Profile',
                value: isTutor,
                onChanged: (val) => setState(() => isTutor = val),
              ),
              _buildReadOnlyField('Email', profile.email),
              _buildReadOnlyField('School Domain', profile.schoolDomain),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfileChanges,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchField(
      {required String label,
      required bool value,
      required void Function(bool) onChanged}) {
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
}
