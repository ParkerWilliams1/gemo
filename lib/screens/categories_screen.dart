import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemo/screens/menu_screen.dart';
import 'package:gemo/matchmaking_service.dart';
import 'package:gemo/screens/waiting_for_match_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isMatching = false;

  final List<Map<String, dynamic>> categories = [
    {"title": "Pop"},
    {"title": "Rock"},
    {"title": "Hip-Hop"},
    {"title": "Jazz"},
    {"title": "Classical"},
    {"title": "EDM"},
  ];

  void _startMatching(String category) async {
    setState(() => _isMatching = true);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WaitingForMatchScreen(
          category: category,
          onCancel: () {
            Navigator.pop(context); // go back to CategoriesScreen
            setState(() => _isMatching = false);
          },
        ),
      ),
    );

    // After matching is complete and user returns, reset state
    if (mounted) {
      setState(() => _isMatching = false);
    }
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
        body: _isMatching
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
                          textStyle: WidgetStateProperty.all(GoogleFonts.inter()),
                          leading: const Icon(Icons.search),
                          elevation: WidgetStateProperty.all(0.0),
                        ),
                      )
                    ],
                  ),
                  _buildCategorySection(context, "Trending Categories"),
                  _buildCategorySection(context, "Majors"),
                  _buildCategorySection(context, "Interests"),
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
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String title) {
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
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () => _startMatching(category["title"]),
                  child: CategoryTile(title: category["title"]),
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
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

  const CategoryTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 110,
          decoration: BoxDecoration(
            color: const Color.fromARGB(111, 158, 158, 158),
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
