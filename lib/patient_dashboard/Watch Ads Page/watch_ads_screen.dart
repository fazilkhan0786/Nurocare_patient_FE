import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:health_chatbot/common/app_background.dart';

class WatchAdsScreen extends StatefulWidget {
  const WatchAdsScreen({super.key});

  @override
  State<WatchAdsScreen> createState() => _WatchAdsScreenState();
}

class _WatchAdsScreenState extends State<WatchAdsScreen> {
  // --- State Management for the Demo ---
  int _careCoins = 0;
  int _adsWatchedToday = 2;
  final int _dailyAdLimit = 10;
  final int _adDurationInSeconds = 60;

  // --- UI and Timer State ---
  bool _isAdPanelVisible = false;
  Timer? _adTimer;
  int _countdown = 60;

  void _handleWatchAdPressed() {
    if (_adsWatchedToday >= _dailyAdLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("You've reached your daily ad limit. Come back tomorrow!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isAdPanelVisible = true;
      _countdown = _adDurationInSeconds;
    });

    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _handleAdCompleted();
      }
    });
  }

  void _handleAdCompleted() {
    _adTimer?.cancel();
    setState(() {
      _isAdPanelVisible = false;
      _careCoins += 5;
      _adsWatchedToday++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Congratulations! You earned 5 Care Coins!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CORRECT IMPLEMENTATION: Layering the backgrounds correctly.
    return Stack(
      children: [
        // 1. The pattern background sits at the very back.
        const AppBackground(),

        // 2. The gradient container sits ON TOP of the pattern, making it visible.
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Top color for the AppBar area
                const Color(0xCC2EB5FA).withAlpha(380),
                const Color(0xCCFFFFFF), // 80% opacity
              ],
              stops: const [0.4, 1.0],
            ),
          ),
        ),

        // 3. The Scaffold is transparent and sits on top of the backgrounds.
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: _CustomAppBar(),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildInfoCards(),
                const SizedBox(height: 24),
                _buildWatchAdButton(),
                const SizedBox(height: 24),
                _buildAnimatedAdPanel(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StatCard(
            value: _careCoins.toString().padLeft(2, '0'),
            label: 'CareCoins',
            iconPath: 'assets/icons/coins.png',
            color: const Color(0xFF7BD8FF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            value: '$_adsWatchedToday/$_dailyAdLimit',
            label: "Ad's Watch Today",
            iconPath: 'assets/icons/play_icon.png',
            color: const Color(0xFF7BD8FF),
          ),
        ),
      ],
    );
  }

  Widget _buildWatchAdButton() {
    final bool canWatchAd = _adsWatchedToday < _dailyAdLimit;
    return GestureDetector(
      onTap: _isAdPanelVisible ? null : _handleWatchAdPressed,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: canWatchAd ? const Color(0xFF75E2F8) : Colors.grey,
          boxShadow: [
            if (canWatchAd)
              BoxShadow(
                color: const Color(0xFF75E2F8).withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
            const SizedBox(width: 8),
            Text(
              canWatchAd ? 'Watch Ad' : 'Limit Reached',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2.0,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAdPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: _isAdPanelVisible ? 250 : 0,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: OverflowBox(
          maxHeight: 250,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://via.placeholder.com/600x250/000000/FFFFFF?text=Ad+Playing...'),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _VideoControls(
                countdown: _countdown,
                totalDuration: _adDurationInSeconds,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom App Bar widget
class _CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF76E8E8), // Make AppBar transparent
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7BD8FF), width: 2),
            ),
            child: Image.asset(
              'assets/icons/play_icon_appbar.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NuroCare',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Watch Ad',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable card widget with font adjustments
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String iconPath;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.iconPath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 4.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 30,
            height: 30,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900, // Heavier weight for impact
                ),
                maxLines: 1,
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85), // Softer white color
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Fake video controls for the ad panel
class _VideoControls extends StatelessWidget {
  final int countdown;
  final int totalDuration;

  const _VideoControls({required this.countdown, required this.totalDuration});

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = 1.0 - (countdown / totalDuration);
    final int currentTime = totalDuration - countdown;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          color: Colors.black.withOpacity(0.2),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(_formatDuration(currentTime),
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(_formatDuration(totalDuration),
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
