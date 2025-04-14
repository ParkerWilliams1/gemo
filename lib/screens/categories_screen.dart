import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemo/screens/menu_screen.dart';
import 'package:gemo/services/matchmaking_service.dart';
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

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    updateCategoryClicks();
  }

  Future<void> updateCategoryClicks() async {
    try {
      List<Category> fetchedCategories = await fetchCategories();
      setState(() {
        for (var fetchedCategory in fetchedCategories) {
          final index = categories
              .indexWhere((cat) => cat["displayName"] == fetchedCategory.name);
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
      Logger("Error fetching trending categories: $e");
      return [];
    }
  }

  void startMatching(String category) async {
    setState(() => _isMatching = true);

    try {
      final categoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .where('displayName', isEqualTo: category)
          .limit(1)
          .get();

      if (categoryDoc.docs.isNotEmpty) {
        final docId = categoryDoc.docs.first.id;
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(docId)
            .update({"clicks": FieldValue.increment(1)});

        setState(() {
          final index =
              categories.indexWhere((cat) => cat["displayName"] == category);
          if (index != -1) {
            categories[index]["clicks"] += 1;
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
  final interestCategories =
      categories.where((cat) => cat["group"] == "interest").toList();
  final majorCategories =
      categories.where((cat) => cat["group"] == "major").toList();

  return Scaffold(
    resizeToAvoidBottomInset: true, // Ensures the body resizes when the keyboard is shown
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black,
      title: Text(
        'Categories',
        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.black, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
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
    body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
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
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        buildCategorySection(
                            context, "Trending", snapshot.data!),
                        buildCategorySection(
                            context, "Interests", interestCategories),
                        buildCategorySection(
                            context, "Majors", majorCategories),
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
                  ),
                );
              }
            },
          ),
      ],
    ),
  );
}

  Widget buildCategorySection(
      BuildContext context, String title, List<Map<String, dynamic>> items) {
    final isTrending = title == "Trending";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
          const SizedBox(height: 10),
          if (isTrending)
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Evenly spread items
              children: items.map((item) {
                return GestureDetector(
                  onTap: () => startMatching(item["displayName"]),
                  child: CategoryTile(
                    title: item["displayName"],
                    image: item["image"] ?? "assets/images/default.png",
                  ),
                );
              }).toList(),
            )
          else
            SizedBox(
              height: 120,
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
                      image: item["image"] ??
                          "assets/images/default.png", // Use image
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
