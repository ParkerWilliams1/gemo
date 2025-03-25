import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class MatchmakingService with ChangeNotifier {
  final List<String> _queue = [];
  final List<Map<String, String>> _matches = [];
  final Logger _logger = Logger(); // Initialize Logger

  List<Map<String, String>> get matches => _matches;

 void joinQueue(String userId) {
    _logger.i("User $userId is joining the queue.");
    _queue.add(userId);
    _logger.d("Current queue: $_queue");
    _tryMatch();
  }

  void leaveQueue(String userId) {
    _logger.i("User $userId is leaving the queue.");
    if (_queue.remove(userId)) {
      _logger.d("User $userId removed from the queue. Current queue: $_queue");
    } else {
      _logger.w("User $userId was not found in the queue.");
    }
    notifyListeners();
  }

 void endCall(String userId1, String userId2) {
    _logger.i("Ending call between $userId1 and $userId2.");

    // Remove the match if it exists
    final matchIndex = _matches.indexWhere((match) =>
        (match['user1'] == userId1 && match['user2'] == userId2) ||
        (match['user1'] == userId2 && match['user2'] == userId1));

    if (matchIndex != -1) {
      _matches.removeAt(matchIndex);
      _logger.d("Match between $userId1 and $userId2 removed. Current matches: $_matches");
    } else {
      _logger.w("No match found between $userId1 and $userId2.");
    }

    // Add users back to the queue
    _queue.add(userId1);
    _queue.add(userId2);
    _logger.d("Users $userId1 and $userId2 added back to the queue. Current queue: $_queue");

    _tryMatch();
  }

  void _tryMatch() {
    _logger.i("Attempting to match users...");
    while (_queue.length >= 2) {
      final user1 = _queue.removeAt(0);
      final user2 = _queue.removeAt(0);
      _matches.add({'user1': user1, 'user2': user2});
      _logger.d("Matched $user1 with $user2. Current matches: $_matches");
      notifyListeners();
    }
    if (_queue.length < 2) {
      _logger.d("Not enough users in the queue to create a match. Current queue: $_queue");
    }
  }
}