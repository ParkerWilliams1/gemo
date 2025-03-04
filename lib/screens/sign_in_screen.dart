import 'package:flutter/material.dart';
import 'package:gemo/auth_service.dart';

class SignInScreen extends StatefulWidget {
   static const routeName = '/signin';
  final VoidCallback toggleScreen;
  const SignInScreen({super.key, required this.toggleScreen});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _signIn() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();
  
  if (email.isNotEmpty && password.isNotEmpty) {
    String? error = await _authService.signIn(email, password);
    
    if (error != null && mounted) {  // Ensure the widget is still mounted before showing SnackBar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            ElevatedButton(onPressed: _signIn, child: const Text("Sign In")),
            TextButton(
              onPressed: widget.toggleScreen,
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
