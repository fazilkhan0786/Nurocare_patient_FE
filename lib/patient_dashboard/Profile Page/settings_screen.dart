// lib/patient_dashboard/Profile Page/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chatbot/common/app_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _allowNotifications = true;
  final _storage = const FlutterSecureStorage();

  // --- NEW: Add controllers for the Change Password dialog ---
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- FUNCTIONALITY METHODS ---

  void _showSnackBar(String message, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green[600] : Colors.red[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- NEW: Full Change Password Logic ---
  Future<void> _showChangeWalletPasswordDialog() async {
    // Clear previous text
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    final storedPassword = await _storage.read(key: 'wallet_password');
    if (storedPassword == null) {
      _showSnackBar('No wallet password is set. Cannot change password.',
          isSuccess: false);
      return;
    }

    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Wallet Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Current Password"),
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "New Password"),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(hintText: "Confirm New Password"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (_oldPasswordController.text != storedPassword) {
                  _showSnackBar('Current password is incorrect.',
                      isSuccess: false);
                  return;
                }
                if (_newPasswordController.text.isEmpty ||
                    _newPasswordController.text !=
                        _confirmPasswordController.text) {
                  _showSnackBar('New passwords do not match or are empty.',
                      isSuccess: false);
                  return;
                }

                // If all checks pass, save the new password
                await _storage.write(
                    key: 'wallet_password', value: _newPasswordController.text);
                if (!mounted) return;
                Navigator.of(context).pop(); // Close the dialog
                _showSnackBar('Wallet password changed successfully!');
              },
            ),
          ],
        );
      },
    );
  }

  // Shows a confirmation dialog before emptying the wallet
  Future<void> _showEmptyWalletConfirmation() async {
    final password = await _storage.read(key: 'wallet_password');
    if (password == null) {
      // If there's no password, we can just empty it directly after confirmation
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Action'),
            content: const Text(
                'Are you sure you want to empty the wallet? This action cannot be undone.'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Confirm & Empty',
                    style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _emptyWallet();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Existing password confirmation logic
    _oldPasswordController.clear(); // Using the same controller for simplicity
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Action'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'To empty the wallet permanently, please enter your current password.'),
              const SizedBox(height: 16),
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(hintText: "Enter Wallet Password"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm & Empty',
                  style: TextStyle(color: Colors.red)),
              onPressed: () async {
                final enteredPassword = _oldPasswordController.text;
                Navigator.of(context).pop(); // Close the dialog first

                if (enteredPassword == password) {
                  await _emptyWallet(); // Proceed with emptying
                } else {
                  _showSnackBar('Incorrect password. Action canceled.',
                      isSuccess: false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Deletes all data associated with the wallet
  Future<void> _emptyWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('medical_records');
    _showSnackBar('All records have been deleted from your wallet.');
  }

  // --- Other Button Functionality ---
  void _resetProfilePassword() =>
      _showSnackBar('Navigating to Reset Password screen...');
  void _deleteAccount() =>
      _showSnackBar('Delete Account action initiated.', isSuccess: false);

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _CustomSettingsAppBar(),
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
                  const Color(0xFF2EB5FA).withAlpha(450),
                  Colors.white.withAlpha(450)
                ],
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7F1FF).withAlpha(200),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Profile', 'Settings:',
                          color: const Color(0xFF38B6FF),
                          textColor1: Colors.white,
                          textColor2: const Color(0xFFAEFFE9)),
                      const SizedBox(height: 12),
                      _buildInfoRow('Last Updated:', 'Yesterday'),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: _buildActionButton('Reset Password',
                                onPressed: _resetProfilePassword)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildActionButton('Delete Account',
                                onPressed: _deleteAccount,
                                isDestructive: true)),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Wallet', 'Settings:',
                          color: const Color(0xFF38B6FF),
                          textColor1: Colors.white,
                          textColor2: const Color(0xFFAEFFE9)),
                      const SizedBox(height: 12),
                      _buildActionButton('Change Password',
                          onPressed:
                              _showChangeWalletPasswordDialog, // <-- FIX: Call the dialog function
                          isFullWidth: true),
                      const SizedBox(height: 12),
                      _buildActionButton('Empty The Wallet',
                          onPressed: _showEmptyWalletConfirmation,
                          isFullWidth: true,
                          isDestructive: true),
                      const SizedBox(height: 24),
                      _buildSectionTitle('App', 'Settings:',
                          color: const Color(0xFF38B6FF),
                          textColor1: Colors.white,
                          textColor2: const Color(0xFFAEFFE9)),
                      const SizedBox(height: 12),
                      _buildNotificationToggle(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  // (No changes needed in the helper widgets below this line)
  Widget _buildSectionTitle(
    String titlePart1,
    String titlePart2, {
    required Color color,
    Color textColor1 = Colors.white,
    Color textColor2 = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titlePart1,
            style: TextStyle(
              color: textColor1,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            titlePart2,
            style: TextStyle(
              color: textColor2,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
            color: const Color(0xFFAEFFE9),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2))
            ]),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
        ]),
      );

  Widget _buildActionButton(String text,
          {required VoidCallback onPressed,
          bool isDestructive = false,
          bool isFullWidth = false}) =>
      SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDestructive ? Colors.white : const Color(0xFFAEFFE9),
            foregroundColor: isDestructive ? Colors.redAccent : Colors.black,
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: isDestructive
                  ? const BorderSide(color: Colors.redAccent, width: 1.5)
                  : BorderSide.none,
            ),
          ),
          child:
              Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );

  Widget _buildNotificationToggle() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
            color: const Color(0xFFAEFFE9),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2))
            ]),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Allow Notification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Switch(
              value: _allowNotifications,
              onChanged: (bool value) =>
                  setState(() => _allowNotifications = value),
              activeThumbColor: const Color(0xFF38B6FF))
        ]),
      );
}

// Custom App Bar (No changes)
class _CustomSettingsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _CustomSettingsAppBar();
  @override
  Widget build(BuildContext context) => AppBar(
      backgroundColor: const Color(0xFF76E8E8),
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop()),
      titleSpacing: 0,
      title: Row(children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.settings, color: Colors.grey, size: 24)),
        const SizedBox(width: 12),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NuroCare',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          Text('Settings',
              style: TextStyle(color: Colors.black54, fontSize: 14))
        ])
      ]));
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
