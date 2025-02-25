import 'package:flutter/material.dart';
import 'package:gemo/pages/register_pages.dart';

import 'login_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();

}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  // initially show login page
  bool showLoginPage = true;

  // toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
  });
}

@override
  Widget build(BuildContext context) {
    return showLoginPage
        ? LoginPage(onTap: togglePages)  
        : RegisterPage(onTap: togglePages); 
  }
}
