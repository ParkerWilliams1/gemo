import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {"title": "Pop", "color": Colors.grey, "icon": Icons.music_note},
    {"title": "Rock", "color": Colors.grey, "icon": Icons.audiotrack},
    {"title": "Hip-Hop", "color": Colors.grey, "icon": Icons.mic},
    {"title": "Jazz", "color": Colors.grey, "icon": Icons.surround_sound},
    {"title": "Classical", "color": Colors.grey, "icon": Icons.album},
    {"title": "EDM", "color": Colors.grey, "icon": Icons.headphones},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
  textDirection: TextDirection.ltr, // Left-to-right text direction
  child: Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: Text("Browse Categories"),
      backgroundColor: Colors.black,
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trending Categories",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          SizedBox(
            height: 130,
            width: double.infinity,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryTile(
                  title: category["title"],
                  color: category["color"]
                );
              },
            ),
          ),
        ],
      ),
    ),
  ),
);

  }
}

class CategoryTile extends StatelessWidget {
  final String title;
  final Color color;
  

  const CategoryTile({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 130, // Ensures fixed width for each tile
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
      
            
      
          ),
        ),
      );
  }
}
