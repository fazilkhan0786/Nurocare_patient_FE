import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the same Stack logic from your ChatScreen, now reusable.
    return Stack(
      children: [
        // Layer 1: The Doodle Image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  "assets/images/Gemini_Generated_Image_mamkd0mamkd0mamk.png"),
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
        // Layer 2: The Dulling Overlay
        Container(
          // Using a dark grey with high opacity to make the doodles very subtle.
          color: const Color(0xFFFBFBFB).withAlpha(800),
        ),
      ],
    );
  }
}
