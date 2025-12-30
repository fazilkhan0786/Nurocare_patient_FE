import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// NEW: Import for navigation to the auth screen
import 'package:health_chatbot/auth/auth_screen.dart';
import 'package:health_chatbot/common/app_background.dart';
import 'package:health_chatbot/main.dart'; // To navigate to ChatScreen
import 'package:health_chatbot/patient_dashboard/Health%20Matrix%20page/health_matrix_screen.dart';
import 'package:health_chatbot/patient_dashboard/Leaderboard%20Page/leaderboard_screen.dart';
import 'package:health_chatbot/patient_dashboard/Watch%20Ads%20Page/watch_ads_screen.dart';
import 'package:health_chatbot/patient_dashboard/book_appointment_page/book_appointment_screen.dart';
// NEW: Import for managing login state
import 'package:shared_preferences/shared_preferences.dart';

import '../Coupon Store Page/coupon_store_page.dart';
import '../Premium Page/premium_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String _userName = 'Patient';
  File? _userImage;
  int _careCoins = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  final List<String> _newsImages = [
    'assets/carousel/360_F_317254576_lKDALRrvGoBr7gQSa1k4kJBx7O2D15dc.jpg',
    'assets/carousel/istockphoto-869939818-612x612.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfileDataForAppBar();

    _currentPage = _newsImages.isNotEmpty ? _newsImages.length * 500 : 0;
    _pageController = PageController(initialPage: _currentPage);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (_newsImages.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadProfileDataForAppBar();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadProfileDataForAppBar() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('profile_name') ?? 'Patient';
      final imagePath = prefs.getString('profile_image_path');
      _userImage = imagePath != null ? File(imagePath) : null;
      _careCoins = prefs.getInt('care_coins') ?? 4000;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // NEW: Logout Method
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    // Remove the user token to log them out
    await prefs.remove('user_token');

    // Navigate to AuthScreen and remove all previous routes
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(leading: Icon(icon), title: Text(text), onTap: onTap);
  }

  @override
  Widget build(BuildContext context) {
    // Your AppBar and Drawer are fully preserved.
    return Center(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF2EB5FA).withAlpha(450),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          title: GestureDetector(
            onTap: () => widget.onNavigate(4), // Profile
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      _userImage != null ? FileImage(_userImage!) : null,
                  backgroundColor: Colors.white70,
                  child: _userImage == null
                      ? const Icon(Icons.person,
                          size: 24, color: Colors.blueAccent)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_getGreeting(),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    Text(_userName,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  Image.asset('assets/icons/coins.png', width: 24, height: 24),
                  const SizedBox(width: 4),
                  Text(_careCoins.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.menu, size: 28, color: Colors.black),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              tooltip: 'Open Menu',
            ),
            const SizedBox(width: 8),
          ],
          backgroundColor: const Color(0xFF76E8E8),
          foregroundColor: Colors.white,
        ),
        endDrawer: Drawer(
          // Your drawer code is preserved
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  _userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black),
                ),
                accountEmail: const Text('View and edit profile',
                    style: TextStyle(color: Colors.black)),
                currentAccountPicture: CircleAvatar(
                  backgroundImage:
                      _userImage != null ? FileImage(_userImage!) : null,
                  backgroundColor: Colors.white,
                  child: _userImage == null
                      ? Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'P',
                          style: const TextStyle(
                              fontSize: 24,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold))
                      : null,
                ),
                decoration: const BoxDecoration(color: Color(0xFF76E8E8)),
                onDetailsPressed: () {
                  Navigator.pop(context);
                  widget.onNavigate(4); // Navigate to Profile
                },
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                        icon: Icons.calendar_today_outlined,
                        text: 'Book Appointment',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BookAppointmentScreen()));
                        }),
                    _buildDrawerItem(
                        icon: FontAwesomeIcons.userDoctor,
                        text: 'Explore Doctors',
                        onTap: () {
                          Navigator.pop(context);
                          widget.onNavigate(0); // Index 0 for Explore
                        }),
                    _buildDrawerItem(
                        icon: Icons.analytics_outlined,
                        text: 'Analyser',
                        onTap: () {
                          Navigator.pop(context);
                          widget.onNavigate(1); // Index 1 for Analyser
                        }),
                    _buildDrawerItem(
                        icon: Icons.account_balance_wallet_outlined,
                        text: 'Wallet',
                        onTap: () {
                          Navigator.pop(context);
                          widget.onNavigate(3); // Index 3 for Wallet
                        }),
                    _buildDrawerItem(
                        icon: Icons.monitor_heart_outlined,
                        text: 'Health Matrix',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const HealthMatrixScreen()));
                        }),
                    _buildDrawerItem(
                        icon: FontAwesomeIcons.medal,
                        text: 'Leaderboard',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LeaderboardScreen(),
                            ),
                          );
                        }),
                    _buildDrawerItem(
                        icon: Icons.slideshow_outlined,
                        text: 'Watch Ads (Earn Coins)',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const WatchAdsScreen()));
                        }),
                    _buildDrawerItem(
                      icon: FontAwesomeIcons.crown,
                      text: 'Go Premium',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ));
                      },
                    ),
                    _buildDrawerItem(
                        icon: Icons.privacy_tip_outlined,
                        text: 'Privacy Policy',
                        onTap: () {
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[300]!))),
                child: _buildDrawerItem(
                    icon: Icons.logout,
                    text: 'Logout',
                    // UPDATED: Call the logout method on tap
                    onTap: _handleLogout),
              ),
            ],
          ),
        ),
        // --- BODY WITH CORRECTLY LAYERED SEMI-CIRCLE BACKGROUNDS ---
        body: Stack(
          children: [
            // Layer 1: Your original pattern background
            const AppBackground(),

            // Layer 2: Your original gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2EB5FA).withAlpha(100),
                    Colors.white.withAlpha(100),
                  ],
                ),
              ),
            ),

            // Layer 3: The top semi-circular background shape
            Positioned(
              top: 0,
              left: -100,
              right: -100,
              child: Container(
                height: 350, // Covers down to Quick Access
                decoration: const BoxDecoration(
                  color: Color(0xFFC0EEFF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.elliptical(500, 150),
                    bottomRight: Radius.elliptical(500, 150),
                  ),
                ),
              ),
            ),

            // --- FIX: Layer 4: The new bottom semi-circular background shape ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(3.14159), // Flip it upside down
                child: Container(
                  height: 130, // Height to cover the Explore More section
                  decoration: const BoxDecoration(
                    color: Color(0xFFC0EEFF),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(500, 150),
                      bottomRight: Radius.elliptical(500, 150),
                    ),
                  ),
                ),
              ),
            ),

            // Layer 5: Your main scrollable content
            ListView(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
              children: [
                _buildNewsSlider(),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage your health\neffectively',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Quick Access:',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickAccessCards(),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Explore More:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // All your original helper widgets are preserved exactly as they were.
  // ... (rest of your file)
  Widget _buildQuickAccessCards() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: _buildBookAppointmentCard(),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: _buildExploreDoctorCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF38B6FF),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSingleActionButton(
              imagePath: 'assets/images/ChatBot.png',
              label: 'ChatBot',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ChatScreen()));
              },
            ),
            _buildSingleActionButton(
              icon: Icons.analytics_outlined,
              label: 'Analyser',
              onTap: () => widget.onNavigate(1),
            ),
            _buildSingleActionButton(
              icon: Icons.slideshow_outlined,
              label: 'Watch Ads',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WatchAdsScreen()));
              },
            ),
            _buildSingleActionButton(
              icon: FontAwesomeIcons.store,
              label: 'Coupons',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        CouponStoreScreen(onNavigate: widget.onNavigate)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleActionButton(
      {IconData? icon,
      String? imagePath,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            padding: imagePath != null ? const EdgeInsets.all(8) : null,
            decoration: BoxDecoration(
              color: const Color(0xFFD7F1FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: imagePath != null
                ? Image.asset(imagePath, fit: BoxFit.contain)
                : Icon(icon, color: Colors.black, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNewsSlider() {
    if (_newsImages.isEmpty) {
      return const SizedBox(height: 180);
    }
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final int realIndex = index % _newsImages.length;
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
              }
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 180,
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(_newsImages[realIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD7F1FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2)
        ],
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 28),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Book Appointment',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAEFFE9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Now book Appointment more faster then before with NuroCare',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/female_doctor.png',
                      fit: BoxFit.cover,
                      height: 130,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD7F1FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(FontAwesomeIcons.userDoctor, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Explore Doctor',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAEFFE9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Explore our available best doctor\'s so you can find best doctor\'s.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/male_doctor.jpg',
                      fit: BoxFit.cover,
                      height: 130,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
