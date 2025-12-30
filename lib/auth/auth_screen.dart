// lib/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:health_chatbot/auth/widgets/login_form.dart';
import 'package:health_chatbot/auth/widgets/signup_form.dart';
import 'package:health_chatbot/common/app_background.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _toggleForm(bool isLogin) {
    setState(() {
      _isLogin = isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background pattern and gradient
          const AppBackground(),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC76E8E8),
                  Color(0xCC2EB5FA),
                  Color(0xCCFFFFFF),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  // App Logo Header
                  if (!_isLogin)
                    const _WelcomeHeader(text: 'Welcome To NuroCare')
                  else
                    const _WelcomeHeader(text: 'NuroCare'),

                  const SizedBox(height: 30),

                  // Main Form Container with shadow effect
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(430),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AuthToggle(
                          isLogin: _isLogin,
                          onToggle: _toggleForm,
                        ),
                        const SizedBox(height: 20),
                        // Animated switcher for a smooth transition between forms
                        AnimatedCrossFade(
                          firstChild: const LoginForm(),
                          secondChild: const SignupForm(),
                          crossFadeState: _isLogin
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 300),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- UPDATED Local Widget for AuthScreen Header ---

class _WelcomeHeader extends StatelessWidget {
  final String text;
  const _WelcomeHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    // Logic to split the text for dual-color effect
    String part1 = text;
    String part2 = 'Care'; // The second part of "NuroCare"

    if (text.contains('Welcome To')) {
      part1 = 'Welcome To Nuro';
    } else {
      part1 = 'Nuro';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF2EB5FA), // Solid blue color for the container
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          // Shadow for the header button
          BoxShadow(
            color: const Color(0xFF2EB5FA).withAlpha(950),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: RichText(
        text: TextSpan(
          // Default style for the first part of the text
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // First part is white
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 3,
                offset: Offset(1, 1),
              )
            ],
          ),
          children: [
            TextSpan(text: part1),
            TextSpan(
              text: part2,
              // Special style for the "Care" part
              style: const TextStyle(
                color: Color(0xFF76E8E8), // Light teal color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthToggle extends StatelessWidget {
  final bool isLogin;
  final Function(bool) onToggle;

  const _AuthToggle({required this.isLogin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(950),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _ToggleButton(
              text: 'Login',
              isSelected: isLogin,
              onTap: () => onToggle(true),
            ),
          ),
          const VerticalDivider(
            width: 2,
            thickness: 1,
            color: Colors.grey,
            indent: 8,
            endIndent: 8,
          ),
          Expanded(
            child: _ToggleButton(
              text: 'Sign Up',
              isSelected: !isLogin,
              onTap: () => onToggle(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton(
      {required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2EB5FA) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected // Shadow for the selected toggle
              ? [
                  BoxShadow(
                    color: const Color(0xFF2EB5FA).withAlpha(950),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.blueGrey,
            ),
          ),
        ),
      ),
    );
  }
}
