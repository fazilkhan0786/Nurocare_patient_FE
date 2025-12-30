import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_chatbot/auth/widgets/auth_widgets.dart';
import 'package:health_chatbot/common/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  Future<void> _handleSignup() async {
    // ---- Dummy Signup Logic ----
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', 'dummy_user_signed_up');

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
        const AuthTextField(hintText: 'Enter Full Name'),
        const SizedBox(height: 15),
        const PhoneTextField(), // Special widget for phone number
        const SizedBox(height: 15),
        const AuthTextField(
            hintText: 'Enter Email', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 15),
        const AuthTextField(hintText: 'Enter Password', isPassword: true),
        const SizedBox(height: 15),
        const AuthTextField(hintText: 'Re-Enter Password', isPassword: true),
        const SizedBox(height: 25),
        AuthButton(text: 'Sign Up', onPressed: _handleSignup),
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
