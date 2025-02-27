import 'package:flutter/material.dart';
import 'package:gemo/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';

  final VoidCallback toggleScreen;
  const SignUpScreen({super.key, required this.toggleScreen});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      String? error = await _authService.signUp(email, password);
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
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white, // Ensuring plain white background
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 78,
                    top: 392,
                    child: SizedBox(
                      width: 247,
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 78,
                    top: 456,
                    child: SizedBox(
                      width: 247,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 84,
                    top: 297,
                    child: Text(
                      'Welcome!',
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 108,
                    top: 596,
                    child: GestureDetector(
                      onTap: widget.toggleScreen,
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account?',
                              style: TextStyle(
                                color: Color(0xFF707070),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: ' ',
                            ),
                            TextSpan(
                              text: 'Log in',
                              style: TextStyle(
                                color: Color(0xFF83B9FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 145,
                    top: 164,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          'lib/images/gemo.png', // Local image with shadow
                          width: 114,
                          height: 114,
                          fit: BoxFit.cover,
                        ),
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
