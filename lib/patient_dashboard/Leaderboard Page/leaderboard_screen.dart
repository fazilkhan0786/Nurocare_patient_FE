// lib/patient_dashboard/Leaderboard Page/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_chatbot/common/app_background.dart';

// A simple model for a user on the leaderboard
class LeaderboardUser {
  final String name;
  final String imageUrl;
  final int steps;
  final int streak;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardUser({
    required this.name,
    required this.imageUrl,
    required this.steps,
    required this.streak,
    required this.rank,
    this.isCurrentUser = false,
  });
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  // Dummy data for the leaderboard
  static const List<LeaderboardUser> _globalRanking = [
    LeaderboardUser(
        name: 'Liza Malek',
        imageUrl: 'assets/images/user_female.png',
        steps: 100000,
        streak: 105,
        rank: 1,
        isCurrentUser: true),
    LeaderboardUser(
        name: 'John Doe',
        imageUrl: 'assets/images/user_male.png',
        steps: 98000,
        streak: 100,
        rank: 2),
    LeaderboardUser(
        name: 'Sara Chokhawala',
        imageUrl: 'assets/images/user_female.png',
        steps: 95000,
        streak: 90,
        rank: 3),
    LeaderboardUser(
        name: 'Moksha Modi',
        imageUrl: 'assets/images/user_female.png',
        steps: 85000,
        streak: 90,
        rank: 4),
    LeaderboardUser(
        name: 'Ben Carter',
        imageUrl: 'assets/images/user_male.png',
        steps: 82000,
        streak: 85,
        rank: 5),
  ];

  static const List<LeaderboardUser> _nationalRanking = [
    LeaderboardUser(
        name: 'Jade West',
        imageUrl: 'assets/images/user_female.png',
        steps: 100000,
        streak: 105,
        rank: 1,
        isCurrentUser: true),
    LeaderboardUser(
        name: 'John Doe',
        imageUrl: 'assets/images/user_male.png',
        steps: 98000,
        streak: 100,
        rank: 2),
    LeaderboardUser(
        name: 'Aarav Sharma',
        imageUrl: 'assets/images/user_male.png',
        steps: 94000,
        streak: 92,
        rank: 3),
    LeaderboardUser(
        name: 'Saanvi Patel',
        imageUrl: 'assets/images/user_female.png',
        steps: 91000,
        streak: 88,
        rank: 4),
    LeaderboardUser(
        name: 'Vihaan Singh',
        imageUrl: 'assets/images/user_male.png',
        steps: 88000,
        streak: 80,
        rank: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2EB5FA),
      appBar: const _CustomAppBar(),
      body: Stack(
        children: [
          const AppBackground(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2EB5FA).withAlpha(150),
                  Colors.white.withAlpha(150),
                ],
              ),
            ),
          ),
          ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFC0EEFF).withAlpha(400), // Adjusted Alpha
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20), // Adjusted Alpha
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildSectionHeader("Global Ranking"),
                    const SizedBox(height: 16),
                    Column(
                      children: _globalRanking
                          .map((user) => _buildUserTile(user))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFC0EEFF).withAlpha(400), // Adjusted Alpha
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20), // Adjusted Alpha
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildSectionHeader("National Ranking"),
                    const SizedBox(height: 16),
                    Column(
                      children: _nationalRanking
                          .map((user) => _buildUserTile(user))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF38B6FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(400),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: Colors.black38,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(LeaderboardUser user) {
    const textShadow = [
      Shadow(
        blurRadius: 2.0,
        color: Colors.black26,
        offset: Offset(1.0, 1.0),
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFa1e8e8),
        borderRadius: BorderRadius.circular(15),
        // --- FIX: Added boxShadow to the user tile ---
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(user.imageUrl),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  shadows: textShadow,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Steps: ${user.steps}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  shadows: textShadow,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Streak: ${user.streak} days',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  shadows: textShadow,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD7F1FF),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(400),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Top:',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${user.rank}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      backgroundColor: const Color(0xFF76E8E8),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              FontAwesomeIcons.medal,
              color: Color(0xFF38B6FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NuroCare',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                'Leader Board',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
