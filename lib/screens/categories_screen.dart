import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemo/screens/menu_screen.dart';
import 'package:gemo/matchmaking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:gemo/screens/combined_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class Category {
  String name;
  int clicks;

  Category(this.name, this.clicks);
}

Future<List<Category>> fetchCategories() async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('categories').get();

  return snapshot.docs
      .map((doc) => Category(doc['displayName'], doc['clicks']))
      .toList();
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  bool _isMatching = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');
  StreamSubscription<DocumentSnapshot>? _matchSubscription;
  String _currentCategory = 'General';

  List<Map<String, dynamic>> categories = [
    // Interests
    {"displayName": "Music", "image": "lib/images/images/music.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Gaming", "image": "lib/images/images/gaming.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Movies", "image": "lib/images/images/movies.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Sports", "image": "lib/images/images/sports.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Travel", "image": "lib/images/images/travel.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Fitness", "image": "lib/images/images/fitness.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Fashion", "image": "lib/images/images/fashion.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Food", "image": "lib/images/images/food.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Photography", "image": "lib/images/images/photography.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Health", "image": "lib/images/images/health.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Business", "image": "lib/images/images/business.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Finance", "image": "lib/images/images/finance.png", "group": "interest", "clicks": 0, "isActive": true},

    // Majors
    {"displayName": "Electrical Engineering", "image": "lib/images/images/electricalengineering.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Calculus", "image": "lib/images/images/calculus.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Physics", "image": "lib/images/images/physics.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Chemistry", "image": "lib/images/images/chemistry.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Economics", "image": "lib/images/images/economics.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Psychology", "image": "lib/images/images/psychology.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "History", "image": "lib/images/images/history.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Computer Science", "image": "lib/images/images/computerscience.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Mechanical Engineering", "image": "lib/images/images/mechanicalengineering.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Civil Engineering", "image": "lib/images/images/civilengineering.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Chemical Engineering", "image": "lib/images/images/chemicalengineering.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Bio Engineering", "image": "lib/images/images/bioengineering.png", "group": "major", "clicks": 0, "isActive": true},
  ];

  @override
  void initState() {
    super.initState();
    updateCategoryClicks();
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    _cleanupWaitingRoom();
    super.dispose();
  }

  Future<void> _cleanupWaitingRoom() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('rooms').doc(uid).delete();
    }
  }

  Future<void> _cancelMatch() async {
    await _cleanupWaitingRoom();
    _matchSubscription?.cancel();
    setState(() => _isMatching = false);
  }

  void _listenForMatch() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _matchSubscription = _firestore
        .collection('rooms')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data()?['status'] == 'matched') {
        _joinVideoRoom(doc.data()?['roomId']);
      }
    });
  }

  void _joinVideoRoom(String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CombinedChatScreen(
          chatId: roomId,
          meetingId: roomId,
          token: "your-hardcoded-jwt-token",
          category: _currentCategory,
        ),
      ),
    ).then((_) => setState(() => _isMatching = false));
  }

  Future<void> updateCategoryClicks() async {
    try {
      List<Category> fetched = await fetchCategories();
      setState(() {
        for (var fetchedCategory in fetched) {
          final index = categories.indexWhere(
              (cat) => cat["displayName"] == fetchedCategory.name);
          if (index != -1) {
            categories[index]["clicks"] = fetchedCategory.clicks;
          }
        }
      });
    } catch (e) {
      Logger("Error updating category clicks: $e");
    }
  }

  Future<List<Map<String, dynamic>>> get trendingCategories async {
    try {
      await Future.delayed(const Duration(milliseconds: 70));
      List<Map<String, dynamic>> sorted = List.from(categories);
      sorted.sort((a, b) => b["clicks"].compareTo(a["clicks"]));
      final trendingData = sorted.take(3).map((cat) => {
            ...cat,
            "image": "images/images/default.png"
          }).toList();

      for (int i = 0; i < trendingData.length; i++) {
        trendingData[i]["image"] = [
          "lib/images/images/gold.png",
          "lib/images/images/silver.png",
          "lib/images/images/bronze.png"
        ][i];
      }

      return trendingData;
    } catch (e) {
      Logger("Trending fetch error: $e");
      return [];
    }
  }

  void startMatching(String category) async {
    setState(() {
      _isMatching = true;
      _currentCategory = category;
    });

    try {
      final snap = await _firestore
          .collection('categories')
          .where('displayName', isEqualTo: category)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await _firestore
            .collection('categories')
            .doc(snap.docs.first.id)
            .update({"clicks": FieldValue.increment(1)});
      }

      final result = await _functions
          .httpsCallable('matchUser')
          .call({'category': category});

      if (result.data['isNewMatch'] == true) {
        _joinVideoRoom(result.data['roomId']);
      } else {
        _listenForMatch();
      }

      setState(() {
        final index =
            categories.indexWhere((cat) => cat["displayName"] == category);
        if (index != -1) {
          categories[index]["clicks"] += 1;
        }
      });
    } catch (e) {
      Logger("Matching error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start match: ${e.toString()}')),
        );
      }
      setState(() => _isMatching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final interestCategories =
        categories.where((c) => c["group"] == "interest").toList();
    final majorCategories =
        categories.where((c) => c["group"] == "major").toList();

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        title: Text('Categories', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20),
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuScreen())),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('images/HomeScreen.png'), fit: BoxFit.cover),
            ),
          ),
          if (_isMatching)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('Finding your match...', style: GoogleFonts.inter(fontSize: 18, color: Colors.black)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _cancelMatch,
                    child: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  ),
                ],
              ),
            )
          else
            FutureBuilder<List<Map<String, dynamic>>>(
              future: trendingCategories,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      buildCategorySection("Trending", snapshot.data!),
                      buildCategorySection("Interests", interestCategories),
                      buildCategorySection("Majors", majorCategories),
                      const SizedBox(height: 60),
                      buildTutorMatchBox(),
                    ],
                  ),
                );
              },
            )
        ],
      ),
    );
  }

  Widget buildCategorySection(String title, List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 15),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return GestureDetector(
                  onTap: () => startMatching(item["displayName"]),
                  child: CategoryTile(title: item["displayName"], image: item["image"]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTutorMatchBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            color: const Color.fromARGB(111, 158, 158, 158),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Let’s find a match for you', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String title;
  final String image;

  const CategoryTile({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(image, width: 80, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
