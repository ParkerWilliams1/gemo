import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const VideoChatScreen(
        peerUserId: '12345',
        chatId: '12345',
      ),
    );
  }
}

class ReportingSystem {
  static const List<String> reportCategories = [
    'Inappropriate content',
    'Harassment/Bullying',
    'Violence/Threat',
    'Spam',
    'Non-CBU Student',
    'Other'
  ];

  static final ReportingSystem _instance = ReportingSystem._internal();
  factory ReportingSystem() => _instance;
  ReportingSystem._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void showReportDialog(BuildContext context, String reportedUserId,
      {String? chatId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReportForm(
        reportedUserId: reportedUserId,
        chatId: chatId, // Pass chatId if available
        onSubmit: (reportData) => _submitReport(context, reportData),
      ),
    );
  }

  Future<bool> _submitReport(
      BuildContext context, Map<String, dynamic> reportData) async {
    try {
      await _firestore.collection('reports').add(reportData);
      return true;
    } catch (e) {
      Logger('Error submitting report: $e');
      return false;
    }
  }
}

class ReportForm extends StatefulWidget {
  final String reportedUserId;
  final String? chatId;
  final Function(Map<String, dynamic>) onSubmit;

  const ReportForm({
    super.key,
    required this.reportedUserId,
    required this.onSubmit,
    this.chatId, // Optional chatId for tracking
  });

  @override
  ReportFormState createState() => ReportFormState();
}

class ReportFormState extends State<ReportForm> {
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a report category')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to report.')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final Map<String, dynamic> reportData = {
      'reportedUserId': widget.reportedUserId,
      'reportingUserId': user.uid,
      'category': _selectedCategory,
      'description': _descriptionController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
      'chatId': widget.chatId, // Optional: Only stored if available
    };

    final bool success = await widget.onSubmit(reportData);

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to submit report. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Report User',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Report Category',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: ReportingSystem.reportCategories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Please provide details about the issue',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Report'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class VideoChatScreen extends StatelessWidget {
  final String peerUserId;
  final String chatId; // New parameter to track chat ID

  const VideoChatScreen(
      {super.key, required this.peerUserId, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem),
            color: Colors.red,
            onPressed: () {
              ReportingSystem()
                  .showReportDialog(context, peerUserId, chatId: chatId);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Video Chat Content Here.'),
      ),
    );
  }
}
