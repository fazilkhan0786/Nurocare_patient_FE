// lib/common/bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_chatbot/patient_dashboard/Doctor%20Explore%20Page/explore_doctor_screen.dart';
import 'package:health_chatbot/patient_dashboard/Home%20Page/home_screen.dart';
import 'package:health_chatbot/patient_dashboard/Profile%20Page/profile_screen.dart';
import 'package:health_chatbot/patient_dashboard/Wallet%20page/wallet_screen.dart';
import 'package:health_chatbot/patient_dashboard/symptom%20analyser%20page/symptom_analyser_page.dart';

// You can keep the global key here if you need to access the state from outside.
final GlobalKey<_BottomNavState> bottomNavKey = GlobalKey<_BottomNavState>();

class BottomNav extends StatefulWidget {
  final int initialIndex;
  const BottomNav({super.key, this.initialIndex = 0});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  // Start on the Home Page (index 2) as per your original main.dart
  int _selectedIndex = 2;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Use the initialIndex if provided, otherwise default to 2
    _selectedIndex = widget.initialIndex != 0 ? widget.initialIndex : 2;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void goToWalletTab() {
    _navigateToTab(3);
  }

  @override
  Widget build(BuildContext context) {
    // Define the pages here to pass the callback function
    final List<Widget> pages = <Widget>[
      const ExploreDoctorScreen(), // 0
      const SymptomAnalyserPage(), // 1
      HomeScreen(onNavigate: _navigateToTab), // 2
      const WalletScreen(), // 3
      const ProfileScreen(), // 4
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        // Disable manual swiping between pages
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(900),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            _buildNavItem(FontAwesomeIcons.userDoctor, 'Explore', 0),
            _buildNavItem(Icons.analytics_outlined, 'Analyser', 1),
            _buildNavItem(Icons.home_outlined, 'Home', 2),
            _buildNavItem(Icons.account_balance_wallet_outlined, 'Wallet', 3),
            _buildNavItem(Icons.person_outline, 'Profile', 4),
          ],
          currentIndex: _selectedIndex,
          onTap: _navigateToTab, // Use the unified navigation function
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: isSelected
            ? Matrix4.translationValues(0, -15, 0)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: isSelected ? 1.25 : 1.0,
          curve: Curves.easeOutBack,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.blueAccent.withAlpha(128),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
      label: isSelected ? '' : '•',
    );
  }
}
