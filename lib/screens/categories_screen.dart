import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemo/screens/menu_screen.dart';
import 'package:gemo/matchmaking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class Category {
  String name;
  int clicks;

  Category(this.name, this.clicks);
}

Future<List<Category>> fetchCategories() async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('categories').get();

  List<Category> categories = snapshot.docs.map((doc) {
    return Category(doc['displayName'], doc['clicks']);
  }).toList();

  return categories;
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  bool _isMatching = false;

  // Combine interests and majors into a single categories map with a "group" field
  List<Map<String, dynamic>> categories = [
    // Interest
    {"displayName": "Music", "color": "0xFF0080FF", "group": "interest", "clicks": 0, "isActive": true}, // Blue
    {"displayName": "Gaming", "color": "0xFF008000", "group": "interest", "clicks": 0, "isActive": true}, // Green
    {"displayName": "Movies", "color": "0xFFff5733", "group": "interest", "clicks": 0, "isActive": true}, // Red
    {"displayName": "Sports", "color": "0xFFFFA500", "group": "interest", "clicks": 0, "isActive": true}, // Orange
    {"displayName": "Travel", "color": "0xFFAC33FF", "group": "interest", "clicks": 0, "isActive": true}, // Purple
    {"displayName": "Fitness", "color": "0xFFFFFF00", "group": "interest", "clicks": 0, "isActive": true}, // Yellow
    {"displayName": "Fashion", "color": "0xFFFE7AE2", "group": "interest", "clicks": 0, "isActive": true}, // Teal
    {"displayName": "Food", "color": "0xFFFFC0CB", "group": "interest", "clicks": 0, "isActive": true}, // Pink
    {"displayName": "Photography", "color": "0xFF00FFFF", "group": "interest", "clicks": 0, "isActive": true}, // Cyan
    {"displayName": "Health", "color": "0xFFFE5EE6", "group": "interest", "clicks": 0, "isActive": true}, // Indigo
    {"displayName": "Business", "color": "0xFF00FF00", "group": "interest", "clicks": 0, "isActive": true}, // Lime
    {"displayName": "Finance", "color": "0xFFFFBF00", "group": "interest", "clicks": 0, "isActive": true}, // Amber

    // Major
    {"displayName": "Electrical Engineering", "color": "0xFFFF5454", "group": "major", "clicks": 0, "isActive": true}, // Red
    {"displayName": "Calculus", "color": "0xFFFFBF00", "group": "major", "clicks": 0, "isActive": true}, // Amber
    {"displayName": "Physics", "color": "0xFF008080", "group": "major", "clicks": 0, "isActive": true}, // Teal
    {"displayName": "Chemistry", "color": "0xFFFFC0CB", "group": "major", "clicks": 0, "isActive": true}, // Pink
    {"displayName": "Economics", "color": "0xFF00FFFF", "group": "major", "clicks": 0, "isActive": true}, // Cyan
    {"displayName": "Psychology", "color": "0xFFA254FF", "group": "major", "clicks": 0, "isActive": true}, // Indigo
    {"displayName": "History", "color": "0xFFE7BB92", "group": "major", "clicks": 0, "isActive": true}, // Lime
    {"displayName": "Computer Science", "color": "0xFF0080FF", "group": "major", "clicks": 0, "isActive": true}, // Blue
    {"displayName": "Mechanical Engineering", "color": "0xFF008000", "group": "major", "clicks": 0, "isActive": true}, // Green
    {"displayName": "Civil Engineering", "color": "0xFFFFA500", "group": "major", "clicks": 0, "isActive": true}, // Orange
    {"displayName": "Chemical Engineering", "color": "0xFF00FF00", "group": "major", "clicks": 0, "isActive": true}, // Purple
    {"displayName": "Bio Engineering", "color": "0xFFFFFF00", "group": "major", "clicks": 0, "isActive": true}, // Yellow
  ];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    updateCategoryClicks(); // Fetch and update clicks
  }

  Future<void> updateCategoryClicks() async {
    try {
      // Fetch categories with clicks from Firestore
      List<Category> fetchedCategories = await fetchCategories();

      // Update the clicks in the local categories map
      setState(() {
        for (var fetchedCategory in fetchedCategories) {
          final index = categories.indexWhere((cat) => cat["displayName"] == fetchedCategory.name);
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

      // Sort categories by clicks in descending order
      List<Map<String, dynamic>> sortedCategories = List.from(categories);
      sortedCategories.sort((a, b) => b["clicks"].compareTo(a["clicks"]));

      // Take the top 3 categories and create a copy to avoid modifying the original list
      final trendingData = sortedCategories.take(3).map((category) {
        return {
          ...category, // Create a copy of the category
          "color": category["color"], // Retain the original color
        };
      }).toList();

      // Assign gold, silver, and bronze colors based on rank
      for (int i = 0; i < trendingData.length; i++) {
        if (i == 0) {
          trendingData[i]["color"] = "0xFFFFD700"; // 0xFFFFD700 Gold
        } else if (i == 1) {
          trendingData[i]["color"] = "0xFFC0C0C0"; // 0xFFC0C0C0 Silver
        } else if (i == 2) {
          trendingData[i]["color"] = "0xFFCD7F32"; // 0xFFCD7F32 Bronze
        }
      }

      return trendingData;
    } catch (e) {
      Logger("Error fetching trending categories: $e");
      return [];
    }
  }

void startMatching(String category) async {
  setState(() => _isMatching = true);

  try {
    // Find the category document in Firestore
    final categoryDoc = await FirebaseFirestore.instance
        .collection('categories')
        .where('displayName', isEqualTo: category) // Match by displayName
        .limit(1)
        .get();

    if (categoryDoc.docs.isNotEmpty) {
      final docId = categoryDoc.docs.first.id;

      // Increment the clicks field in Firestore
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(docId)
          .update({"clicks": FieldValue.increment(1)});

      // Update the local categories list
      setState(() {
        final index = categories.indexWhere((cat) => cat["displayName"] == category);
        if (index != -1) {
          categories[index]["clicks"] += 1; // Increment the local clicks count
        }
      });
    }
  } catch (e) {
    Logger("Error updating category clicks in Firestore: $e");
  }

  if (mounted) {
    await MatchmakingService().startCategoryChat(context, category);
    setState(() => _isMatching = false);
  }
}

  @override
  Widget build(BuildContext context) {
    // Filter categories by group
    final interestCategories =
        categories.where((cat) => cat["group"] == "interest").toList();
    final majorCategories =
        categories.where((cat) => cat["group"] == "major").toList();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black,
          title: Text(
            'Categories',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              padding: const EdgeInsets.only(right: 20),
              icon: const Icon(Icons.menu, color: Colors.black, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                );
              },
            ),
          ],
          elevation: 1,
        ),
        body: Stack(children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/HomeScreen.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (_isMatching)
            const Center(child: CircularProgressIndicator())
          else
            FutureBuilder<List<Map<String, dynamic>>>(
              future: trendingCategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading trending categories.',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Text(
                      'No trending categories yet.',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40), // Add spacing above "Trending Categories"
                        // Trending Categories Section
                        buildCategorySection(
                          context,
                          "Trending",
                          snapshot.data!,
                        ),
                        // Interest Categories Section
                        buildCategorySection(
                          context,
                          "Interests",
                          interestCategories,
                        ),
                        // Major Categories Section
                        buildCategorySection(
                          context,
                          "Majors",
                          majorCategories,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 70, top: 80),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Looking for a tutor?",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        buildTutorMatchBox(),
                      ],
                    ),
                  );
                }
              },
            ),
        ]),
      ),
    );
  }

Widget buildCategorySection(
  BuildContext context, String title, List<Map<String, dynamic>> items) {
  final isTrending = title == "Trending";
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        if (isTrending)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 15), // Add horizontal offset for trending boxes
              ...items.map((item) {
                return GestureDetector(
                  onTap: () => startMatching(item["displayName"]),
                  child: CategoryTile(
                    title: item["displayName"],
                    color: item["color"], // Pass the hex string
                  ),
                );
              }),
            ],
          )
        else
          SizedBox(
            height: 90,
            width: MediaQuery.of(context).size.width * 0.9,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => startMatching(item["displayName"]),
                  child: CategoryTile(
                    title: item["displayName"],
                    color: item["color"], // Pass the hex string
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(111, 158, 158, 158),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Let’s find a match for you',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
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
  final String color; // Changed to String to accept hex strings
  const CategoryTile({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 110,
          height: 90,
          decoration: BoxDecoration(
            color: color.isNotEmpty
                ? Color(int.tryParse(color) ?? 0xFFFFFFFF)
                : const Color(0xFFFFFFFF), 
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
