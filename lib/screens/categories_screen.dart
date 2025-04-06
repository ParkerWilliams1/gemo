import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemo/screens/menu_screen.dart';
import 'package:gemo/matchmaking_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isMatching = false;

  final Map<String, Color> categories = {
    "Music": Colors.blue,
    "Gaming": Colors.green,
    "Movies": Colors.red,
    "Sports": Colors.orange,
    "Travel": Colors.purple,
    "Fitness": Colors.yellow,
    "Fashion": Colors.teal,
    "Food": Colors.pink,
    "Photography": Colors.cyan,
    "Health": Colors.indigo,
    "Business": Colors.lime,
    "Finance": Colors.amber,
  };

  final Map<String, Color> majors = {
    "Electrical Engineering": Colors.red,
    "Calculus": Colors.amber,
    "Physics": Colors.teal,
    "Chemistry": Colors.pink,
    "Economics": Colors.cyan,
    "Psychology": Colors.indigo,
    "History": Colors.lime,
    "Computer Science": Colors.blue,
    "Mechanical Engineering": Colors.green,
    "Civil Engineering": Colors.orange,
    "Chemical Engineering": Colors.purple,
    "Bio Engineering": Colors.yellow,
  };

  // Getter to convert the majors map into a list of maps
  List<Map<String, dynamic>> get categoriesList => categories.entries
      .map((entry) => {"title": entry.key, "color": entry.value})
      .toList();

  List<Map<String, dynamic>> get majorsList => majors.entries
      .map((entry) => {"title": entry.key, "color": entry.value})
      .toList();

  void _startMatching(String category) async {
    setState(() => _isMatching = true);
    await MatchmakingService().startCategoryChat(context, category);
    if (mounted) setState(() => _isMatching = false);
  }

  @override
  Widget build(BuildContext context) {
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
                image: AssetImage(
                    'assets/HomeScreen.png'), // Correct path to your image
                fit: BoxFit.cover,
              ),
            ),
          ),
          _isMatching
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: SearchBar(
                            hintText: 'Search for a specific category',
                            textStyle:
                                WidgetStateProperty.all(GoogleFonts.inter()),
                            leading: const Icon(Icons.search),
                            elevation: WidgetStateProperty.all(0.0),
                          ),
                        )
                      ],
                    ),
                    _buildCategorySection(
                        context, "Trending Categories", categoriesList),
                    _buildCategorySection(context, "Majors", majorsList),
                    _buildCategorySection(
                        context, "All Categories", categoriesList),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
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
                    _buildTutorMatchBox(),
                  ],
                ),
        ]),
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context, String title, List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 90,
            width: MediaQuery.of(context).size.width * 0.9,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => _startMatching(item["title"]),
                  child: CategoryTile(
                    title: item["title"],
                    color: item["color"], // Use the color from the list
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorMatchBox() {
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
  final Color color; // Add a color parameter

  const CategoryTile({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 110,
          decoration: BoxDecoration(
            color: color, // Use the passed color
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
