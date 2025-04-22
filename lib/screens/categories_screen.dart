import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemo/screens/menu_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:gemo/services/match_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  static const String routeName = '/category';
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  bool _isMatching = false;
  final MatchService _matchService = MatchService();

  List<Map<String, dynamic>> categories = [
      // Interests
    {"displayName": "Music", "image": "assets/images/music.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Gaming", "image": "assets/images/gaming.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Movies", "image": "assets/images/movies.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Sports", "image": "assets/images/sports.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Travel", "image": "assets/images/travel.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Fitness", "image": "assets/images/fitness.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Fashion", "image": "assets/images/fashion.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Food", "image": "assets/images/food.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Photography", "image": "assets/images/photography.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Health", "image": "assets/images/health.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Business", "image": "assets/images/business.png", "group": "interest", "clicks": 0, "isActive": true},
    {"displayName": "Finance", "image": "assets/images/finance.png", "group": "interest", "clicks": 0, "isActive": true},

    // Majors
    {"displayName": "Electrical Engineering", "image": "assets/images/electricalengineering.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Calculus", "image": "assets/images/calculus.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Physics", "image": "assets/images/physics.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Chemistry", "image": "assets/images/chemistry.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Economics", "image": "assets/images/economics.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Psychology", "image": "assets/images/psychology.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "History", "image": "assets/images/history.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Computer Science", "image": "assets/images/computerscience.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Mechanical Engineering", "image": "assets/images/mechanicalengineering.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Civil Engineering", "image": "assets/images/civilengineering.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Chemical Engineering", "image": "assets/images/chemicalengineering.png", "group": "major", "clicks": 0, "isActive": true},
    {"displayName": "Bio Engineering", "image": "assets/images/bioengineering.png", "group": "major", "clicks": 0, "isActive": true},
  ];

  @override
  void initState() {
    super.initState();
    updateCategoryClicks();
  }

  @override
  void dispose() {
    _matchService.dispose();
    super.dispose();
  }

  Future<void> _cancelMatch() async {
    await _matchService.cancelMatch();
    setState(() => _isMatching = false);
  }

  void _joinVideoRoom(String roomId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MatchService().createChatScreen(roomId),
    ),
  ).then((_) => setState(() => _isMatching = false));
  }

  Future<void> updateCategoryClicks() async {
    try {
      List<Category> fetched = await fetchCategories();
      setState(() {
        for (var cat in fetched) {
          final index = categories.indexWhere((c) => c["displayName"] == cat.name);
          if (index != -1) {
            categories[index]["clicks"] = cat.clicks;
          }
        }
      });
    } catch (e) {
      Logger("Error updating category clicks: $e");
    }
  }

  Future<String?> _getUserMajor() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    return doc.data()?['major'] as String?;
  } catch (e) {
    Logger("Error fetching user major: $e");
    return null;
  }
}

  Future<List<Map<String, dynamic>>> get trendingCategories async {
    try {
      await Future.delayed(const Duration(milliseconds: 70));
      List<Map<String, dynamic>> sortedCategories = List.from(categories);
      sortedCategories.sort((a, b) => b["clicks"].compareTo(a["clicks"]));

      final trendingData = sortedCategories.take(3).map((category) {
        return {
          ...category,
          "image": null, // Placeholder for image path
        };
      }).toList();

      for (int i = 0; i < trendingData.length; i++) {
        if (i == 0) {
          trendingData[i]["image"] = "assets/images/gold.png"; // Gold
        } else if (i == 1) {
          trendingData[i]["image"] = "assets/images/silver.png"; // Silver
        } else if (i == 2) {
          trendingData[i]["image"] = "assets/images/bronze.png"; // Bronze
        }
      }

      return trendingData;
    } catch (e) {
      Logger("Trending fetch error: $e");
      return [];
    }
  }

  void startMatching(String category) async {
    _matchService.startMatch(
      category: category,
      context: context,
      onMatchStarted: () => setState(() => _isMatching = true),
      onMatchFound: (roomId) => _joinVideoRoom(roomId),
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
          setState(() => _isMatching = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final interestCategories = categories.where((c) => c["group"] == "interest").toList();
    final majorCategories = categories.where((c) => c["group"] == "major").toList();

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
              image: DecorationImage(image: AssetImage('assets/HomeScreen.png'), fit: BoxFit.cover),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: const Text('Cancel'),
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
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 15),
        if (title == "Trending")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              return GestureDetector(
                onTap: () => startMatching(item["displayName"]),
                child: CategoryTile(
                  title: item["displayName"],
                  image: item["image"],
                ),
              );
            }).toList(),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return GestureDetector(
                  onTap: () => startMatching(item["displayName"]),
                  child: CategoryTile(
                    title: item["displayName"],
                    image: item["image"],
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );
}

Widget buildTutorMatchBox() {
  return Column(
    children: [
      const Text(
        'Tutors',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              final major = await _getUserMajor();
              if (major != null) {
                startMatching(major);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not determine your major')),
                );
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                color: const Color.fromARGB(111, 158, 158, 158),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Let\'s find a match for you',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
}

class CategoryTile extends StatelessWidget {
  final String title;
  final String image;
  final bool isTrending;

  const CategoryTile(
      {super.key,
      required this.title,
      required this.image,
      this.isTrending = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image,
              width: 80,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
              height: 2), // Add spacing between the image and the title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black, // Black text color
                fontSize: isTrending ? 10 : 14, // Larger font for trending
                fontWeight: isTrending ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}