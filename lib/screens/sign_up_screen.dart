import 'package:flutter/material.dart';
import 'package:gemo/auth_service.dart';


class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  final VoidCallback toggleScreen;
  const SignUpScreen({super.key, required this.toggleScreen});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      String? error = await _authService.signUp(email, password);
      if (!mounted) return; 
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Verification email sent! Check your inbox.")));
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
            ElevatedButton(onPressed: _signUp, child: const Text("Sign Up")),
            TextButton(
              onPressed: widget.toggleScreen,
              child: const Text("Already have an account? Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}
