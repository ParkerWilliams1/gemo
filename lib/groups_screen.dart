import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupsScreen extends StatelessWidget {
   GroupsScreen({super.key});
  
  final List<Map<String, dynamic>> categories = [
    {"title": "Pop",},
    {"title": "Rock", },
    {"title": "Hip-Hop",  },
    {"title": "Jazz", },
    {"title": "Classical", },
    {"title": "EDM", },
  ];
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child:  Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black,
          title: 
          Text('Categories', 
          style: GoogleFonts.inter(
            fontSize: 24, 
            fontWeight: FontWeight.bold
            ),  
         ),
          actions: <Widget> [ IconButton( padding: EdgeInsets.only(right: 20),
            icon: Icon(Icons.menu, color: Colors.black, size: 28,),
            onPressed: (){},
          ),
          ],
          elevation: 1,
        ),
        body: Column(children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          Row( mainAxisAlignment: MainAxisAlignment.center,
             children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.9,
            child:  SearchBar(
            hintText: 'Search for a specific category', 
            textStyle: WidgetStateProperty.all(GoogleFonts.inter()), 
            leading: Icon(Icons.search),
            elevation: WidgetStateProperty.all(0.0),
            ),)
         
          ]
          ),
          
          Row( mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Padding(
      padding: const EdgeInsets.only(top: 20, left:  10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trending Categories",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
         SizedBox(
  height: 90, // Fix the height
  width: MediaQuery.of(context).size.width * 0.9, // Allow full width but not infinite
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: categories.length,
    itemBuilder: (context, index) {
      final category = categories[index];
      return CategoryTile(
        title: category["title"],
      );
    },
  ),
),


        ],
      ),
    ),
          ]
          ),
          Row( mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Padding(
      padding: const EdgeInsets.symmetric( vertical: 10 , horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Majors",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
         SizedBox(
  height: 90, // Fix the height
  width: MediaQuery.of(context).size.width * 0.9, // Allow full width but not infinite
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: categories.length,
    itemBuilder: (context, index) {
      final category = categories[index];
      return CategoryTile(
        title: category["title"],
        
      );
    },
  ),
),


        ],
      ),
    ),
          ]
          ),
          Row( mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Padding(
      padding: const EdgeInsets.symmetric( vertical: 10,   horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Interests",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
         SizedBox(
  height: 90, // Fix the height
  width: MediaQuery.of(context).size.width * 0.9, // Allow full width but not infinite
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: categories.length,
    itemBuilder: (context, index) {
      final category = categories[index];
      return CategoryTile(
        title: category["title"],
      );
    },
  ),
),


        ],
      ),
    ),
          ]
          ),
           Row( mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.025,),
            Padding(
      padding: const EdgeInsets.symmetric( vertical: 10 , horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Looking for a tutor?",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
          ]
          ),
          SizedBox(height: 15),
          Row( mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Padding(
      padding: const EdgeInsets.symmetric( vertical: 10,),
            ),
             ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:  Container(
          width: 300,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(111, 158, 158, 158),
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Lets find a match for you',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
        ],
      ),
    )
        ),
        ],)
        ],
      ),
      )
    );
  }
}
class CategoryTile extends StatelessWidget {
  final String title;
  
  

  const CategoryTile({
    required this.title,
    
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 110, // Ensures fixed width for each tile
          decoration: BoxDecoration(
            color: const Color.fromARGB(111, 158, 158, 158),
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
                        color: Colors.black,
                        fontSize: 14,
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
