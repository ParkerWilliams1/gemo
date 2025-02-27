import 'package:flutter/material.dart';
import 'package:gemo/auth_service.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signin';

  final VoidCallback toggleScreen;
  const SignInScreen({super.key, required this.toggleScreen});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      String? error = await _authService.signIn(email, password);

      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white, // Ensuring pure white background
          ),
          Center(
            child: Container(
              width: 402,
              height: 874,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "lib/images/background.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 63,
                    top: 287,
                    child: Container(
                      width: 277,
                      height: 338,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 89,
                    top: 330,
                    child: Text(
                      'Sign In to Your Gemo Account',
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 78,
                    top: 392,
                    child: Container(
                      width: 247,
                      height: 43,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Color(0xFF707070)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 78,
                    top: 456,
                    child: Container(
                      width: 247,
                      height: 43,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Color(0xFF707070)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 232,
                    top: 504,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF83B9FF),
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 78,
                    top: 528,
                    child: GestureDetector(
                      onTap: _signIn,
                      child: Container(
                        width: 247,
                        height: 55,
                        decoration: ShapeDecoration(
                          color: Color(0xFF83B9FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 87,
                    top: 140,
                    child: Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 30,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 89,
                    top: 600,
                    child: TextButton(
                      onPressed: widget.toggleScreen,
                      child: Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Color(0xFF83B9FF)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
