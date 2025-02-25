import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuScreen extends StatelessWidget{
  const MenuScreen({super.key});

   final iconalignment = IconAlignment.start;

  @override
  Widget build(BuildContext context) {
     return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          shadowColor: Colors.black,
          title: Text('Menu', 
          style: GoogleFonts.inter(
            fontWeight:FontWeight.bold, 
            fontSize: 24, 
            color:  Colors.black
            )
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 28,),
              onPressed: (){},
            ),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.23,),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 40),
            Container(
              
              child: TextButton.icon(onPressed: (){},
              icon: Icon(Icons.groups_outlined, size: 57, color: Colors.black,),
              iconAlignment: iconalignment,
               label:Text('My Chats', 
              style: GoogleFonts.inter(
                fontWeight:FontWeight.bold, 
                fontSize: 24, 
                color:  Colors.black
                )
                ), ) 
            ),
            SizedBox(height: 40,),
             Container(
            
              child: TextButton.icon(onPressed: (){},
              icon: Icon(Icons.person_outline_outlined, size: 57, color: Colors.black,),
               label:Text('Profile', 
              style: GoogleFonts.inter(
                fontWeight:FontWeight.bold, 
                fontSize: 24, 
                color:  Colors.black
                )
                ), ) 
            ),
            SizedBox(height: 40,),
            Container(
              
              child: TextButton.icon(onPressed: (){},
              icon: Icon(Icons.settings_outlined, size: 57, color: Colors.black,),
               label:Text('Settings', 
              style: GoogleFonts.inter(
                fontWeight:FontWeight.bold, 
                fontSize: 24, 
                color:  Colors.black
                )
                ), ) 
            ),
            SizedBox(height: 40,),
            Container(
              child: TextButton.icon(onPressed: (){},
              icon: Icon(Icons.logout, size: 57, color: Colors.black,),
               label:Text('Logout', 
              style: GoogleFonts.inter(
                fontWeight:FontWeight.bold, 
                fontSize: 24, 
                color:  Colors.black
                )
                ), ) 
            ),
            
          ],
        ),
      )
        
      ),
      
    );
  }
}