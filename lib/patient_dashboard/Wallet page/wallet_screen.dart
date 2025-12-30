// lib/patient_dashboard/Wallet page/wallet_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chatbot/common/app_background.dart';
import 'package:health_chatbot/models/medical_record.dart';
import 'package:health_chatbot/patient_dashboard/Doctor%20Explore%20Page/doctor_model.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // --- STATE MANAGEMENT ---
  Map<String, List<MedicalRecord>> _groupedRecords = {};
  bool _isLoading = true;
  bool _isLocked = true;
  bool _passwordIsSet = false;

  // --- SECURE STORAGE & CONTROLLERS ---
  final _storage = const FlutterSecureStorage();
  final _passwordController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPasswordAndLoad();
  }

  @override
  void dispose() {
    if (_passwordIsSet) {
      _isLocked = true;
    }
    _passwordController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- DATA HANDLING ---
  Future<void> _checkPasswordAndLoad() async {
    final storedPassword = await _storage.read(key: 'wallet_password');
    if (mounted) {
      setState(() {
        _passwordIsSet = storedPassword != null;
        _isLocked = _passwordIsSet;
        _isLoading = false;
      });
      if (!_isLocked) {
        _loadMedicalRecords();
      }
    }
  }

  Future<void> _loadMedicalRecords() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString('grouped_medical_records');
      if (mounted) {
        if (recordsJson != null) {
          final Map<String, dynamic> decoded = jsonDecode(recordsJson);
          _groupedRecords = decoded.map((key, value) {
            final records = (value as List)
                .map((item) => MedicalRecord.fromJson(item))
                .toList();
            return MapEntry(key, records);
          });
        } else {
          // For demo purposes, add some records if none are found
          _groupedRecords = {
            "My Records": [
              MedicalRecord(
                  title: 'Ai Analyser Report',
                  date: DateTime(2025, 10, 31),
                  icon: Icons.description,
                  filePath: ''),
              MedicalRecord(
                  title: 'Lab Report',
                  date: DateTime(2025, 10, 31),
                  icon: Icons.description,
                  filePath: ''),
            ],
            "Mom Records": [
              MedicalRecord(
                  title: 'Hospital Prescription',
                  date: DateTime(2025, 10, 31),
                  icon: Icons.description,
                  filePath: ''),
            ],
            "Dad Records": [
              MedicalRecord(
                  title: 'Annual Check-up',
                  date: DateTime(2025, 9, 15),
                  icon: Icons.description,
                  filePath: ''),
            ]
          };
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveMedicalRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> encoded = _groupedRecords.map((key, value) {
      final recordsJson = value.map((record) => record.toJson()).toList();
      return MapEntry(key, recordsJson);
    });
    await prefs.setString('grouped_medical_records', jsonEncode(encoded));
  }

  // --- ACTIONS ---
  Future<void> _unlockWallet() async {
    final storedPassword = await _storage.read(key: 'wallet_password');
    if (!mounted) return;
    if (_passwordController.text == storedPassword) {
      setState(() {
        _isLocked = false;
        _isLoading = true;
      });
      await _loadMedicalRecords();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Incorrect Password'), backgroundColor: Colors.red),
      );
    }
    _passwordController.clear();
  }

  Future<void> _showSetPasswordDialog() async {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    if (_passwordIsSet) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: "Old Password"),
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
                  final storedPassword =
                      await _storage.read(key: 'wallet_password');
                  if (_oldPasswordController.text != storedPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Old password is incorrect.'),
                        backgroundColor: Colors.red));
                    return;
                  }
                  if (_newPasswordController.text.isEmpty ||
                      _newPasswordController.text !=
                          _confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('New passwords do not match.'),
                        backgroundColor: Colors.red));
                    return;
                  }
                  await _storage.write(
                      key: 'wallet_password',
                      value: _newPasswordController.text);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  setState(() => _isLocked = true);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Password Changed! Please unlock your wallet again.'),
                      backgroundColor: Colors.green));
                },
              ),
            ],
          );
        },
      );
    } else {
      _passwordController.clear();
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Set New Password'),
            content: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration:
                  const InputDecoration(hintText: "Enter a new password"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () async {
                  if (_passwordController.text.isNotEmpty) {
                    await _storage.write(
                        key: 'wallet_password',
                        value: _passwordController.text);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    setState(() {
                      _passwordIsSet = true;
                      _isLocked = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Password Saved! Please unlock your wallet.'),
                        backgroundColor: Colors.green));
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _addRecord() async {
    if (_isLocked) {
      if (!_passwordIsSet) {
        _showSetPasswordDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please unlock the wallet first.'),
              backgroundColor: Colors.orange),
        );
      }
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);
      final fileName = p.basename(pickedFile.path);

      final selectedCategory = await showDialog<String>(
        context: context,
        builder: (context) => _CategorySelectionDialog(
          existingCategories: _groupedRecords.keys.toList(),
        ),
      );

      if (selectedCategory == null || selectedCategory.isEmpty) {
        return; // User canceled
      }

      final documentsDir = await getApplicationDocumentsDirectory();
      final newPath = p.join(documentsDir.path, fileName);
      final newFile = await pickedFile.copy(newPath);

      final newRecord = MedicalRecord(
        title: fileName.replaceAll(p.extension(fileName), ''),
        date: DateTime.now(),
        icon: fileName.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image,
        filePath: newFile.path,
      );

      setState(() {
        if (_groupedRecords.containsKey(selectedCategory)) {
          _groupedRecords[selectedCategory]!.insert(0, newRecord);
        } else {
          _groupedRecords[selectedCategory] = [newRecord];
        }
      });

      await _saveMedicalRecords();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Record added to "$selectedCategory" successfully!'),
            backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _deleteRecord(MedicalRecord record, String category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete "${record.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        if (record.filePath.isNotEmpty) {
          final file = File(record.filePath);
          if (await file.exists()) {
            await file.delete();
          }
        }
        setState(() {
          _groupedRecords[category]?.remove(record);
          if (_groupedRecords[category]?.isEmpty ?? false) {
            _groupedRecords.remove(category);
          }
        });
        await _saveMedicalRecords();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Record deleted'), backgroundColor: Colors.green));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting record: $e')),
        );
      }
    }
  }

  Future<void> _downloadRecord(MedicalRecord record) async {
    if (record.filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('This is a demo record and cannot be downloaded.')));
      return;
    }
    if (await Permission.storage.request().isGranted) {
      try {
        final downloadsDir = await getExternalStorageDirectory();
        if (downloadsDir != null) {
          final newPath =
              p.join(downloadsDir.path, p.basename(record.filePath));
          await File(record.filePath).copy(newPath);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Saved to Downloads folder: ${p.basename(newPath)}')));
        } else {
          throw Exception("Could not find downloads directory");
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  void _showShareDialog(MedicalRecord record) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ShareDoctorSheet(record: record),
    );
  }

  void _viewRecord(String filePath) {
    if (filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('This is a demo record and has no file.')));
      return;
    }
    OpenFile.open(filePath);
  }

  // --- UI BUILDERS ---
  @override
  Widget build(BuildContext context) {
    // CORRECT IMPLEMENTATION: A Stack as the root to layer the gradient behind the Scaffold.
    return Stack(
      children: [
        // The pattern background sits at the very back.
        const AppBackground(),

        // The gradient container sits on top of the pattern.
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Top color for the AppBar area
                const Color(0xCC2EB5FA)
                    .withAlpha(380), // Using hex for alpha (CC = 80%)
                const Color(0xCCFFFFFF), // Using hex for alpha
              ],
              stops: const [0.4, 1.0],
            ),
          ),
        ),

        // The Scaffold is transparent and sits on top of the backgrounds.
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _CustomAppBar(onSettingsTap: _showSetPasswordDialog),
          body: SafeArea(
            child: _buildBody(),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_passwordIsSet) {
      return _buildSetupWallet();
    }
    if (_isLocked) {
      return _buildPasswordEntry();
    }
    return _buildUnlockedWallet();
  }

  Widget _buildUnlockedWallet() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: _SectionHeader(title1: 'Claimed ', title2: 'Coupons:'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 255,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 8),
              children: const [
                _CouponCard(
                    isClaimed: false,
                    status: 'Unclaimed',
                    couponId: 'a10101',
                    daysLeft: '10 days left'),
                SizedBox(width: 12),
                _CouponCard(
                    isClaimed: true, status: 'Claimed', buttonText: 'Used'),
                SizedBox(width: 12),
                _CouponCard(
                    isClaimed: false,
                    status: 'Unclaimed',
                    couponId: 'b20202',
                    daysLeft: '5 days left'),
                SizedBox(width: 12),
                _CouponCard(
                    isClaimed: true, status: 'Claimed', buttonText: 'Used'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionHeader(title1: 'Medical ', title2: 'Records:'),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.add_box_outlined,
                            color: Colors.grey),
                        onPressed: _addRecord,
                        tooltip: 'Add Record'),
                    IconButton(
                        icon: const Icon(Icons.lock_open_outlined,
                            color: Colors.lightGreen),
                        onPressed: () => setState(() => _isLocked = true),
                        tooltip: 'Lock Wallet'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildRecordList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordList() {
    if (_groupedRecords.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          'No medical records found.\nTap the + icon to create a category and add your first record!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ));
    }

    final sortedKeys = _groupedRecords.keys.toList()
      ..sort((a, b) {
        if (a == 'My Records') return -1;
        if (b == 'My Records') return 1;
        return a.compareTo(b);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedKeys.map((category) {
        final records = _groupedRecords[category]!;
        if (records.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(400),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecordSubHeader(title: '$category:'),
              const SizedBox(height: 8),
              ...records.map((record) => _RecordCard(
                    record: record,
                    onView: () => _viewRecord(record.filePath),
                    onShare: () => _showShareDialog(record),
                    onDownload: () => _downloadRecord(record),
                    onDelete: () => _deleteRecord(record, category),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSetupWallet() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.security_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text('Secure Your Wallet',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        blurRadius: 2,
                        color: Colors.black26,
                        offset: Offset(0, 1))
                  ])),
          const SizedBox(height: 8),
          Text(
            'To protect your medical records, please set a password for your wallet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showSetPasswordDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Set a Password'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordEntry() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.create_new_folder_rounded,
                        color: Colors.white70),
                    tooltip: 'Add Record (Locked)',
                    onPressed: _addRecord,
                  ),
                  IconButton(
                    icon: const Icon(Icons.lock, color: Colors.red),
                    tooltip: 'Wallet Locked',
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.lock_outline, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                const Text('Wallet Locked',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        shadows: [
                          Shadow(
                              blurRadius: 2,
                              color: Colors.black26,
                              offset: Offset(0, 1))
                        ])),
                const SizedBox(height: 8),
                Text(
                  'Please enter your password to unlock your medical records.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    fillColor: Colors.white.withAlpha(400),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Colors.blueAccent, width: 2)),
                  ),
                  onSubmitted: (_) => _unlockWallet(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _unlockWallet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Unlock Wallet',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- WIDGETS ---

class _SectionHeader extends StatelessWidget {
  final String title1;
  final String title2;
  const _SectionHeader({required this.title1, required this.title2});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2EB5FA),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF2EB5FA).withAlpha(170),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4))
          ],
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [
                  Shadow(
                      blurRadius: 2.0,
                      color: Colors.black26,
                      offset: Offset(2, 3.0))
                ]),
            children: <TextSpan>[
              TextSpan(
                  text: title1,
                  style: const TextStyle(
                      color: Color(0xFFD7F1FF), fontWeight: FontWeight.bold)),
              TextSpan(
                  text: title2,
                  style: const TextStyle(
                      color: Color(0xFF76E8E8), fontWeight: FontWeight.bold)),
            ],
          ),
        ));
  }
}

class _CouponCard extends StatelessWidget {
  final bool isClaimed;
  final String status;
  final String? couponId;
  final String? daysLeft;
  final String buttonText;

  const _CouponCard({
    required this.isClaimed,
    required this.status,
    this.couponId,
    this.daysLeft,
    this.buttonText = 'Claimed',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade200),
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text("Harsheyl's 100gr Protein",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          const Text("Best protein to hit the gym buy now before it gets over",
              style: TextStyle(color: Colors.black, fontSize: 11)),
          const Spacer(),
          if (daysLeft != null)
            Text(daysLeft!,
                style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
          const SizedBox(height: 4),
          if (isClaimed)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2EB5FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(buttonText,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2EB5FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                  child: Text('Coupon I\'d: $couponId',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold))),
            ),
          const SizedBox(height: 5),
          Center(
              child: Text('Status: $status',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _RecordSubHeader extends StatelessWidget {
  final String title;
  const _RecordSubHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                        blurRadius: 1.0,
                        color: Colors.black38,
                        offset: Offset(1, 2.0))
                  ])),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '------------------',
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsTap;
  const _CustomAppBar({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF76E8E8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      elevation: 0,
      title: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF6DD8FE),
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NuroCare',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17)),
              Text('Patient\'s Wallet',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: onSettingsTap,
            tooltip: 'Wallet Settings'),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _RecordCard extends StatelessWidget {
  final MedicalRecord record;
  final VoidCallback onView;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _RecordCard(
      {required this.record,
      required this.onView,
      required this.onDownload,
      required this.onShare,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF76E8E8),
      elevation: 4,
      shadowColor: const Color(0xFF76E8E8).withAlpha(1500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf_outlined,
                    color: Colors.black, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(DateFormat('MMM dd, yyyy').format(record.date),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined,
                      color: Colors.black),
                  onPressed: onView,
                  tooltip: 'View Record',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _ActionButton(
                    label: 'Download',
                    icon: Icons.download,
                    onPressed: onDownload),
                const SizedBox(width: 8),
                _ActionButton(
                    label: 'Share', icon: Icons.share, onPressed: onShare),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton(
      {required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF2EB5FA),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

// --- DIALOG AND OTHER WIDGETS ---

class _CategorySelectionDialog extends StatefulWidget {
  final List<String> existingCategories;

  const _CategorySelectionDialog({required this.existingCategories});

  @override
  State<_CategorySelectionDialog> createState() =>
      __CategorySelectionDialogState();
}

class __CategorySelectionDialogState extends State<_CategorySelectionDialog> {
  String? _selectedCategory;
  bool _isCreatingNew = false;
  final _newCategoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existingCategories.contains("My Records")) {
      _selectedCategory = "My Records";
    }
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_newCategoryController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(_isCreatingNew ? 'Create New Category' : 'Select a Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _isCreatingNew
                ? [
                    TextFormField(
                      controller: _newCategoryController,
                      autofocus: true,
                      decoration: const InputDecoration(
                          hintText: "e.g., Child's Records",
                          border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Category name cannot be empty.';
                        }
                        if (widget.existingCategories.any((c) =>
                            c.toLowerCase() == value.trim().toLowerCase())) {
                          return 'This category already exists.';
                        }
                        return null;
                      },
                    )
                  ]
                : [
                    ...widget.existingCategories
                        .map((category) => RadioListTile<String>(
                              title: Text(category),
                              value: category,
                              groupValue: _selectedCategory,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                            )),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.add_circle_outline,
                          color: Colors.blueAccent),
                      title: const Text('Add New Category'),
                      onTap: () {
                        setState(() {
                          _isCreatingNew = true;
                        });
                      },
                    )
                  ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_isCreatingNew)
          ElevatedButton(
            onPressed: _handleCreate,
            child: const Text('Create'),
          )
        else
          ElevatedButton(
            onPressed: _selectedCategory == null
                ? null
                : () => Navigator.of(context).pop(_selectedCategory),
            child: const Text('Select'),
          ),
      ],
    );
  }
}

class _ShareDoctorSheet extends StatefulWidget {
  final MedicalRecord record;
  const _ShareDoctorSheet({required this.record});

  @override
  __ShareDoctorSheetState createState() => __ShareDoctorSheetState();
}

class __ShareDoctorSheetState extends State<_ShareDoctorSheet> {
  final List<Doctor> _allDoctors = [
    Doctor(
        id: '1',
        name: 'Dr. John Doe',
        specialty: 'Cardiologist',
        rating: 4.5,
        reviewCount: 120,
        initials: 'JD',
        phone: '',
        experience: '',
        age: 0,
        location: '',
        gender: '',
        availability: '',
        isVerified: true,
        hospital: '',
        distance: 2),
    Doctor(
        id: '2',
        name: 'Dr. Jane Smith',
        specialty: 'Dermatologist',
        rating: 4.8,
        reviewCount: 95,
        initials: 'JS',
        phone: '',
        experience: '',
        age: 0,
        location: '',
        gender: '',
        availability: '',
        isVerified: true,
        hospital: '',
        distance: 3),
  ];
  List<Doctor> _filteredDoctors = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredDoctors = _allDoctors;
    _searchController.addListener(filterDoctors);
  }

  void filterDoctors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = _allDoctors
          .where((doctor) =>
              doctor.name.toLowerCase().contains(query) ||
              doctor.specialty.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Share with a Doctor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or specialty...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = _filteredDoctors[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(doctor.initials)),
                  title: Text(doctor.name),
                  subtitle: Text(doctor.specialty),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Shared "${widget.record.title}" with ${doctor.name}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
