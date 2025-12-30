import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:health_chatbot/common/app_background.dart';
import 'package:health_chatbot/main.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // --- Page 1 ---
        _buildSplashPage(
          body: _buildSplashPage1Content(onStartNow: () {
            _pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }),
        ),
        // --- Page 2 ---
        _buildSplashPage(
          body: _buildSplashPage2Content(onContinue: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AuthWrapper()),
            );
          }),
        ),
      ],
    );
  }

  // --- Reusable Page Builder with CORRECT Layering ---
  Widget _buildSplashPage({required Widget body}) {
    return Scaffold(
      // The body of the Scaffold is a Stack to layer all background effects.
      body: Stack(
        fit: StackFit.expand, // Make stack children fill the screen
        children: [
          // Layer 1 (Bottom): The doodle effect from your widget
          const AppBackground(),

          // Layer 2 (Middle): The gradient on top of the doodle
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

          // Layer 3 (Top): Main page content
          body,
        ],
      ),
    );
  }

  // Builds the first page's central content
  Widget _buildSplashPage1Content({required VoidCallback onStartNow}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 1),
            const _NuroCareLogo(),
            const Spacer(flex: 3),
            // UPDATED: Added deep shadow to the card
            Container(
              padding: const EdgeInsets.fromLTRB(20, 35, 20, 35),
              decoration: BoxDecoration(
                color: const Color(0xFFD4F3FF).withAlpha(680),
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(800),
                    blurRadius: 25,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.asset('assets/images/splash.png', height: 210),
                  const SizedBox(height: 25),
                  // UPDATED: Added shadow to heading
                  const Text(
                    'One app to store all your\nmedical reports',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF455A64),
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Experience life's momentum with\nhealth at your command.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Color(0xFF607D8B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 4),
            _SplashButton(
              // Pass the two parts of the text to the button
              textPart1: 'Start ',
              textPart2: 'now',
              onPressed: onStartNow,
            ),
            const Spacer(flex: 1),
            const _Footer(),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  // Builds the second page's central content
  Widget _buildSplashPage2Content({required VoidCallback onContinue}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 1),
            const _NuroCareLogo(),
            const Spacer(flex: 3),
            // UPDATED: Added deep shadow to the card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
              decoration: BoxDecoration(
                color: const Color(0xFFD4F3FF).withAlpha(680),
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(800),
                    blurRadius: 25,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  // UPDATED: Added shadow to heading
                  Text(
                    'Customize your health',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF455A64),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF455A64),
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Select at least 3 health topics:',
                    style: TextStyle(fontSize: 15, color: Color(0xFF607D8B)),
                  ),
                  SizedBox(height: 30),
                  _HealthTopicsGrid(),
                ],
              ),
            ),
            const Spacer(flex: 4),
            // For the "Continue" button, we only need one part
            _SplashButton(textPart1: 'Continue', onPressed: onContinue),
            const Spacer(flex: 1),
            const _Footer(),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

// UPDATED: "NuroCare" Logo with dual-color text
class _NuroCareLogo extends StatelessWidget {
  const _NuroCareLogo();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2EB5FA),
        borderRadius: BorderRadius.circular(30),
        // Enhanced shadow
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005A8C).withAlpha(400),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: RichText(
        text: const TextSpan(
          // Default style for the "Nuro" part
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black38,
                blurRadius: 4,
                offset: Offset(1, 1),
              )
            ],
          ),
          children: <TextSpan>[
            TextSpan(text: 'Nuro', style: TextStyle(color: Color(0xFFD7F1FF))),
            // Special style for the "Care" part
            TextSpan(
              text: 'Care',
              style: TextStyle(
                color: Color(0xFF76E8E8), // Light teal/cyan color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Health Topics Grid with deeper shadows
class _HealthTopicsGrid extends StatefulWidget {
  const _HealthTopicsGrid();

  @override
  State<_HealthTopicsGrid> createState() => _HealthTopicsGridState();
}

class _HealthTopicsGridState extends State<_HealthTopicsGrid> {
  final List<String> _topics = [
    'Nutrition',
    'Mental Health',
    'Fitness',
    'Illness',
    'Symptoms',
    'Diabetes',
    'Healthy Habits',
    'lifestyles',
    'Health Matrix',
    'Medication',
    'Reminders',
    'Daily Updates'
  ];
  final Set<String> _selectedTopics = {'Symptoms', 'Medication', 'Reminders'};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _topics.map((topic) {
        final isSelected = _selectedTopics.contains(topic);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedTopics.remove(topic);
              } else {
                _selectedTopics.add(topic);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2EB5FA)
                  : const Color(0xFFD7F1FF),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color:
                    isSelected ? Colors.transparent : const Color(0xFFB0E2FF),
                width: 2,
              ),
              // Enhanced shadows for both states
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF005A8C).withAlpha(900)
                      : Colors.black.withAlpha(600),
                  blurRadius: isSelected ? 12 : 8,
                  spreadRadius: isSelected ? 1 : 0,
                  offset: isSelected ? const Offset(0, 6) : const Offset(0, 4),
                )
              ],
            ),
            child: Text(
              topic,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF455A64),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// CORRECTED: Main action button to be full-width
class _SplashButton extends StatelessWidget {
  final String textPart1;
  final String? textPart2; // Make the second part optional
  final VoidCallback onPressed;
  const _SplashButton(
      {required this.textPart1, this.textPart2, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // This SizedBox forces the button to fill the available width
    return SizedBox(
      width: double.infinity,
      child: Container(
        // This outer container casts the deep shadow
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF005A8C).withAlpha(950),
              blurRadius: 20.0,
              spreadRadius: -5.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2EB5FA),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            // Set elevation to 0 as the shadow is handled by the outer Container
            elevation: 0,
          ),
          child: RichText(
            text: TextSpan(
              // Default style for the first part
              style: const TextStyle(
                color: Color(0xFFD7F1FF),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 5,
                    offset: Offset(1, 1),
                  )
                ],
              ),
              children: [
                TextSpan(text: textPart1),
                if (textPart2 != null)
                  TextSpan(
                    text: textPart2,
                    style: const TextStyle(
                      color: Color(0xFF76E8E8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Footer with clickable links
class _Footer extends StatelessWidget {
  const _Footer();

  // Helper method to launch a URL
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      // You can show a snackbar or print an error if the URL can't be launched
      print('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define your actual URLs here
    const String privacyPolicyUrl = 'https://your-company.com/privacy';
    const String termsUrl = 'https://your-company.com/terms';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
            fontSize: 12,
            color: Color(
                0xFF455A64), // Dark color for visibility on light gradient
            height: 1.5),
        children: [
          const WidgetSpan(
            child: Icon(Icons.copyright, size: 14, color: Color(0xFF455A64)),
            alignment: PlaceholderAlignment.middle,
          ),
          const TextSpan(text: ' 2026 NuroCare, All rights reserved.\n'),
          const TextSpan(text: 'Check Out Our '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
            // Use the helper method in the recognizer
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _launchURL(privacyPolicyUrl);
              },
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'terms of condition',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
            // Use the helper method in the recognizer
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _launchURL(termsUrl);
              },
          ),
        ],
      ),
    );
  }
}
