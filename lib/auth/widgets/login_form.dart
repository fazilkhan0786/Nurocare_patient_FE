import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_chatbot/auth/widgets/auth_widgets.dart';
import 'package:health_chatbot/common/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    // ---- Dummy Login Logic ----
    // In a real app, you would validate credentials against a server.
    // For this demo, we'll just save a dummy token to simulate a login.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', 'dummy_user_logged_in');

    // Navigate to the main app screen and remove all previous routes
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const BottomNav()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PolicyText(),
        const SizedBox(height: 20),
        AuthTextField(
          controller: _emailController,
          hintText: 'Enter Email/Phone Number',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        AuthTextField(
          controller: _passwordController,
          hintText: 'Enter Password',
          isPassword: true,
        ),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Forgot Password?',
            style: TextStyle(
                color: Color(0xFF007BFF), fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 25),
        AuthButton(text: 'Login', onPressed: _handleLogin),
        const SizedBox(height: 20),
        const SocialDivider(),
        const SizedBox(height: 20),
        SocialLoginButton(
          icon: FontAwesomeIcons.google,
          text: 'Continue With Google',
          color: const Color(0xFFDB4437),
          onPressed: () {},
        ),
        const SizedBox(height: 15),
        SocialLoginButton(
          icon: FontAwesomeIcons.facebook,
          text: 'Continue With Facebook',
          color: const Color(0xFF4267B2),
          onPressed: () {},
        ),
      ],
    );
  }
}
