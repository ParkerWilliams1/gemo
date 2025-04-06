import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gemo/auth_service.dart';
import 'package:gemo/screens/home_screen.dart';
import 'package:gemo/screens/sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signin';

  const SignInScreen({super.key});

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error!)));
      } else {
        // Navigate to HomeScreen upon successful login
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Welcome Back Text
          const Positioned(
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
          // White Card Container
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
          // Sign-In Title
          const Positioned(
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
          // Email Label
          const Positioned(
            left: 93,
            top: 384,
            child: Text(
              'Email',
              style: TextStyle(
                color: Color(0xFF707070),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Email Input Field
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
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
          ),
          // Password Label
          const Positioned(
            left: 93,
            top: 448,
            child: Text(
              'Password',
              style: TextStyle(
                color: Color(0xFF707070),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Password Input Field
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
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
          ),
          // Forgot Password Text
          const Positioned(
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
          // Sign-In Button
          Positioned(
            left: 78,
            top: 528,
            child: GestureDetector(
              onTap: _signIn,
              child: Container(
                width: 247,
                height: 55,
                decoration: ShapeDecoration(
                  color: const Color(0xFF83B9FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Center(
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
          // Sign-Up Link
          Positioned(
            left: 110,
            top: 600,
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: 'Sign Up',
                    style: const TextStyle(
                      color: Color(0xFF83B9FF),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacementNamed(context, SignUpScreen.routeName);
                      },
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
