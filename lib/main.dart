// lib/main.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_chatbot/auth/auth_screen.dart';
// Import the new splash screen you created
import 'package:health_chatbot/splash/splash_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'patient_dashboard/Doctor Explore Page/explore_doctor_screen.dart';
import 'patient_dashboard/Home Page/home_screen.dart';
import 'patient_dashboard/Profile Page/profile_screen.dart';
import 'patient_dashboard/Wallet page/wallet_screen.dart';
import 'patient_dashboard/symptom analyser page/symptom_analyser_page.dart';

final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

void main() {
  runApp(const HealthChatbotApp());
}

class HealthChatbotApp extends StatelessWidget {
  const HealthChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // MODIFICATION: Start the app with the SplashScreen.
      // The SplashScreen will then navigate to the AuthWrapper.
      home: const SplashScreen(),
    );
  }
}

// NO CHANGES are needed for the rest of your file.
// Your AuthWrapper, MainScreen, ChatScreen, and other classes remain exactly as they were.

// NEW WIDGET: This widget checks login status and shows the correct screen.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<bool> _isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Check for the token that we will save upon successful login/signup.
    return prefs.getString('user_token') != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        // While checking, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // If snapshot has data and the user is logged in (true)
        if (snapshot.hasData && snapshot.data == true) {
          // Go to the main app screen
          return MainScreen(key: mainScreenKey);
        } else {
          // Otherwise, go to the authentication screen
          return const AuthScreen();
        }
      },
    );
  }
}

// ... ALL YOUR OTHER CODE (MainScreen, ChatScreen, etc.) REMAINS UNCHANGED ...
class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // Start on Home
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
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
    // Animate to the new page in the PageView
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

// ... (Your Message and ChatScreen classes remain unchanged)
class Message {
  final String role;
  final String content;
  Message({required this.role, required this.content});
  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(role: json['role'], content: json['content']);
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  final String _baseUrl = 'http://localhost:8000';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _messages.add(
      Message(
        role: 'assistant',
        content: "Hello! I'm your health assistant. How can I help you today?",
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty || _isLoading) return;
    final userMessage = Message(role: 'user', content: _textController.text);
    setState(() {
      _messages.add(userMessage);
      _textController.clear();
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': _messages.map((m) => m.toJson()).toList(),
          'user_id': 'default_user',
        }),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final botMessage = Message(
          role: 'assistant',
          content: jsonResponse['response'],
        );
        setState(() => _messages.add(botMessage));
      } else {
        setState(
          () => _messages.add(
            Message(
              role: 'assistant',
              content: "Sorry, I encountered an error. Please try again.",
            ),
          ),
        );
      }
    } catch (e) {
      setState(
        () => _messages.add(
          Message(
            role: 'assistant',
            content:
                "Sorry, I couldn't connect to the server. Please make sure the backend is running.",
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF2EB5FA).withAlpha(500),
      appBar: AppBar(
        titleSpacing: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/images/ChatBot.png"),
              radius: 20,
              backgroundColor: Colors.transparent,
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NuroCare',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Health Chatbot',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 2),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF76E8E8),
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF76E8E8)),
              child: Text(
                'Chat Options',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View History'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Chat'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Clear Chat'),
              onTap: () {
                setState(() {
                  _messages.clear();
                  _messages.add(
                    Message(
                      role: 'assistant',
                      content:
                          "Hello! I'm your health assistant. How can I help you today?",
                    ),
                  );
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Save Chat'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/Gemini_Generated_Image_mamkd0mamkd0mamk.png",
                ),
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  const Color(0xFF2EB5FA).withAlpha(450),
                  Colors.white.withAlpha(450),
                ])),
          ),
          Column(
            children: [
              // --- ADDITION START ---
              const _DisclaimerBanner(),
              // --- ADDITION END ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(_messages[index]),
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 10),
                      Text(
                        'Thinking...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.role == 'user';
    Widget avatar;
    if (isUser) {
      avatar = const CircleAvatar(
        backgroundColor: Color(0xFFC4FDFD),
        child: Icon(Icons.person, color: Colors.black, size: 24.0),
      );
    } else {
      avatar = const CircleAvatar(
        backgroundImage: AssetImage("assets/images/ChatBot.png"),
        backgroundColor: Colors.transparent,
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) avatar,
          if (!isUser) const SizedBox(width: 12.0),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: isUser ? 60.0 : 0,
                right: isUser ? 0 : 60.0,
              ),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF2EB5FA),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.black87 : Colors.black87,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 12.0),
          if (isUser) avatar,
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Type your health question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        color: const Color(0xFF2EB5FA),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        color: const Color(0xFF2EB5FA),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8.0),
            FloatingActionButton(
              onPressed: _sendMessage,
              backgroundColor: const Color(0xFF2EB5FA),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NEW, REDESIGNED WIDGET ADDED HERE ---
class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Semi-transparent white background to blend in
        color: const Color(0xFFD9534F).withAlpha(940),
        borderRadius: BorderRadius.circular(12),
        // Subtle border to define the shape
        border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
        boxShadow: [
          // Soft shadow to lift it off the background
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded, // Using a more neutral 'info' icon
            color: Colors.red, // A deep but soft blue
            size: 24,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This tool is for informational purposes only and does not provide medical advice, diagnosis, or treatment. It is not a substitute for professional healthcare. If you are experiencing a medical emergency, call your local emergency services (e.g., 911) immediately.',
              style: TextStyle(
                color: Color.fromARGB(
                    255, 218, 220, 221), // Darker, more readable text
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
