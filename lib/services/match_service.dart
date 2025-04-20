import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  final _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> findMatch(String category) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final result = await _functions
          .httpsCallable('matchUser')
          .call({'cat': category});

      return result.data;
    } catch (e) {
      throw Exception('Match failed: ${e.toString()}');
    }
  }
}