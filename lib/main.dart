import 'package:flutter/material.dart';
import 'screens/screen_home.dart'; // Import the HomeScreen file
import 'screens/profile_screen.dart'; // Import the ProfileScreen file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String firstName = '';
  String lastName = '';
  String major = '';
  String subjects = '';

  void _navigateToProfileScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          firstName: firstName,
          lastName: lastName,
          major: major,
          subjects: subjects,
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        firstName = result['firstName'];
        lastName = result['lastName'];
        major = result['major'];
        subjects = result['subjects'];
      });
    }
  }

  void _navigateToHomeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Tap a button to navigate:',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToProfileScreen,
              child: const Text('Go to Profile Screen'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _navigateToHomeScreen,
              child: const Text('Go to Home Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
