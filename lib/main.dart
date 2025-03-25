import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gemo/screens/chat_search_screen.dart';
import 'package:gemo/screens/my_chats_screen.dart';
import 'services/firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/waiting_for_match_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/text_chat_screen.dart';
import 'video_stream/join_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      // initialRoute: SplashScreen.routeName,
      initialRoute: JoinScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        ChatHomeScreen.routeName: (context) => ChatHomeScreen(),
        SignInScreen.routeName: (context) => const SignInScreen(),
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        CategoriesScreen.routeName: (context) => CategoriesScreen(),
        WaitingForMatchScreen.routeName: (context) => const WaitingForMatchScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        MyChatsScreen.routeName: (context) => const MyChatsScreen(),
        TextChatScreen.routeName: (context) => const TextChatScreen(chatId: 'chat_queue'),
        ChatSearchScreen.routeName: (context) => const ChatSearchScreen(),
        JoinScreen.routeName: (context) => JoinScreen(),
      },
    );
  }
}
