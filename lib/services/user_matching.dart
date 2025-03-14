import 'package:flutter/material.dart';

class MatchmakingService with ChangeNotifier {
  final List<String> _queue = [];
  final List<Map<String, String>> _matches = [];

  List<Map<String, String>> get matches => _matches;

  void joinQueue(String userId) {
    _queue.add(userId);
    _tryMatch();
  }

  void leaveQueue(String userId) {
    _queue.remove(userId);
    notifyListeners();
  }

  void endCall(String userId1, String userId2) {
    _matches.removeWhere((match) => match['user1'] == userId1 && match['user2'] == userId2);
    _queue.add(userId1);
    _queue.add(userId2);
    _tryMatch();
  }

  void _tryMatch() {
    while (_queue.length >= 2) {
      final user1 = _queue.removeAt(0);
      final user2 = _queue.removeAt(0);
      _matches.add({'user1': user1, 'user2': user2});
      notifyListeners();
    }
  }
}