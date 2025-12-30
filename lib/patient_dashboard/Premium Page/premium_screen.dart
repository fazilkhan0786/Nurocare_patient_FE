// lib/patient_dashboard/premium_page/premium_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_chatbot/common/app_background.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _PremiumAppBar(),
      extendBodyBehindAppBar: true,
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
          SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              children: [
                _buildBenefitsCard(),
                const SizedBox(height: 24),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _BuildPlusPlanColumn()),
                    SizedBox(width: 16),
                    Expanded(child: _BuildProPlanColumn()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF87CEEB).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('Premium Benefits', FontAwesomeIcons.award),
          const SizedBox(height: 12),
          const Text(
            'Premium users save ₹1,000+ per year on health tools & services',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem('Advanced Ai Symptom Analyser: (Plus)',
              'Understand possible causes, severity & next steps in minutes.'),
          _buildBenefitItem('Family Health Wallet: (Pro)',
              'Manage reports & health data for parents, kids & loved ones.'),
          _buildBenefitItem('Unlimited Medical Records Storage: (Plus)',
              'Never lose prescriptions, reports or bills again.'),
          _buildBenefitItem('Advanced Health Tracking & Insights: (Plus)',
              'See your health trends and improve daily habits.'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF38B6FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38B6FF).withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.yellow[600], size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(FontAwesomeIcons.check, size: 24, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 15, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildPlusPlanColumn extends StatelessWidget {
  const _BuildPlusPlanColumn();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF87CEEB).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPlanHeader('NuroCare ', 'Plus', const Color(0xFF76E8E8)),
          const SizedBox(height: 12),
          _buildPlanOptionCard('-Monthly: ₹149', '₹149', 'Per Month', () {}),
          const SizedBox(height: 12),
          _buildPlanOptionCard('-Yearly: ₹999', '₹85', 'Per Month', () {}),
          const SizedBox(height: 12),
          _buildBestFor('Individuals'),
        ],
      ),
    );
  }
}

class _BuildProPlanColumn extends StatelessWidget {
  const _BuildProPlanColumn();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF87CEEB).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPlanHeader('NuroCare ', 'Pro', const Color(0xFF76E8E8)),
          const SizedBox(height: 12),
          _buildPlanOptionCard('-Monthly: ₹299', '₹299', 'Per Month', () {}),
          const SizedBox(height: 12),
          _buildPlanOptionCard('-Yearly: ₹1,999', '₹165', 'Per Month', () {}),
          const SizedBox(height: 12),
          _buildBestFor('Families'),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ---

Widget _buildPlanHeader(String part1, String part2, Color nuroCareColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF38B6FF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(FontAwesomeIcons.solidStar, color: Colors.yellow[600], size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Roboto'),
              children: [
                TextSpan(
                  text: part1,
                  style: TextStyle(color: nuroCareColor), // Teal Color
                ),
                TextSpan(
                  text: part2,
                  style: const TextStyle(color: Colors.black), // White
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// FIX: This is the only widget that has been changed to get the dual-color button text.
Widget _buildPlanOptionCard(
    String title, String price, String period, VoidCallback onPressed) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFD7F1FF),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
                fontSize: 14)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(price,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black87)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(period,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38B6FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto'),
                children: [
                  TextSpan(
                    text: 'Choose ',
                    style: TextStyle(color: Colors.white), // "Choose" is white
                  ),
                  TextSpan(
                    text: 'Plan',
                    style:
                        TextStyle(color: Color(0xFF76E8E8)), // "Plan" is teal
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildBestFor(String text) {
  return Column(
    children: [
      const Text('Best for:',
          style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
              fontWeight: FontWeight.w500)),
      Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.black87)),
    ],
  );
}

class _PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PremiumAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF76E8E8),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(FontAwesomeIcons.crown,
                color: Colors.yellow, size: 22),
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
                    fontSize: 20),
              ),
              Text(
                'Purchase Premium',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
