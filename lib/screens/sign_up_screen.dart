import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gemo/auth_service.dart';
import 'package:gemo/screens/setup_profile_screen.dart';
import 'package:gemo/screens/sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _emailError;

  void _signUp() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

  // Email must end in .edu
  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.edu$').hasMatch(email)) {
    setState(() {
      _emailError = "Please enter a valid .edu email address";
    });
    return;
  } else {
    setState(() {
      _emailError = null;
    });
  }

  if (email.isNotEmpty && password.isNotEmpty) {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.sendEmailVerification();

      final uid = userCredential.user?.uid;
      if (uid != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileSetupScreen(uid: uid),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Error occurred")),
        );
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          // App Icon
          Positioned(
            left: 145,
            top: 164,
            child: Container(
              width: 114,
              height: 114,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/gemo.png'),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(64),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
            ),
          ),
          // Welcome Text
          const Positioned(
            left: 84,
            top: 297,
            child: Text(
              'Welcome!',
              style: TextStyle(
                color: Color(0xFF707070),
                fontSize: 48,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Email Label
          const Positioned(
            left: 93,
            top: 375,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 247,
                  height: 43,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      errorText: _emailError, // Show error message if email is invalid
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Password Label
          const Positioned(
            left: 93,
            top: 439,
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
          // Sign Up Button Container
          Positioned(
            left: 78,
            top: 528,
            child: GestureDetector(
              onTap: _signUp,
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
                    'Sign Up',
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
          // "Already have an account?" Text
          Positioned(
            left: 108,
            top: 596,
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Already have an account?',
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(
                    text: ' ',
                  ),
                  TextSpan(
                    text: 'Log in',
                    style: const TextStyle(
                      color: Color(0xFF83B9FF),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacementNamed(context, SignInScreen.routeName);
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
