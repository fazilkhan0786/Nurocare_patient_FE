import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:health_chatbot/common/app_background.dart';
import 'package:health_chatbot/patient_dashboard/Profile%20Page/app_info_screen.dart';
import 'package:health_chatbot/patient_dashboard/Profile%20Page/settings_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// GuardianContact class now includes a country code for each contact.
class GuardianContact {
  final int id;
  late TextEditingController nameController;
  late TextEditingController numberController;
  String countryCode;

  GuardianContact(
      {String name = '', String number = '', this.countryCode = '+91'})
      : id = DateTime.now().millisecondsSinceEpoch {
    nameController = TextEditingController(text: name);
    numberController = TextEditingController(text: number);
  }

  Map<String, dynamic> toJson() => {
        'name': nameController.text,
        'number': numberController.text,
        'countryCode': countryCode,
      };

  factory GuardianContact.fromJson(Map<String, dynamic> json) =>
      GuardianContact(
        name: json['name'] ?? '',
        number: json['number'] ?? '',
        countryCode: json['countryCode'] ?? '+91',
      );

  void dispose() {
    nameController.dispose();
    numberController.dispose();
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  File? _profileImage;
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _contactController = TextEditingController();

  String? _selectedGender;
  String _countryCode = '+91';

  List<GuardianContact> _guardianContacts = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _bloodGroupController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _contactController.dispose();
    for (var contact in _guardianContacts) {
      contact.dispose();
    }
    super.dispose();
  }

  // --- LOGIC FOR LOADING AND SAVING DATA ---
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nameController.text = prefs.getString('profile_name') ?? '';
      _dobController.text = prefs.getString('profile_dob') ?? '';
      _selectedGender = prefs.getString('profile_gender');
      _contactController.text = prefs.getString('profile_contact') ?? '';
      _emailController.text = prefs.getString('profile_email') ?? '';
      _bloodGroupController.text = prefs.getString('profile_bloodGroup') ?? '';
      _allergiesController.text = prefs.getString('profile_allergies') ?? '';
      _conditionsController.text = prefs.getString('profile_conditions') ?? '';
      _countryCode = prefs.getString('profile_country_code') ?? '+91';

      final imagePath = prefs.getString('profile_image_path');
      if (imagePath != null) {
        _profileImage = File(imagePath);
      }

      final guardiansJson = prefs.getString('profile_guardians');
      if (guardiansJson != null) {
        final List<dynamic> decoded = jsonDecode(guardiansJson);
        for (var contact in _guardianContacts) {
          contact.dispose();
        }
        _guardianContacts =
            decoded.map((item) => GuardianContact.fromJson(item)).toList();
      }
    });
  }

  Future<void> _saveProfile() async {
    final isNameFilled = _nameController.text.isNotEmpty;
    final isDobFilled = _dobController.text.isNotEmpty;
    final isGenderSelected = _selectedGender != null;
    final isContactFilled = _contactController.text.isNotEmpty;
    final isEmailFilled = _emailController.text.isNotEmpty;
    final isBloodGroupFilled = _bloodGroupController.text.isNotEmpty;

    if (isNameFilled &&
        isDobFilled &&
        isGenderSelected &&
        isContactFilled &&
        isEmailFilled &&
        isBloodGroupFilled) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', _nameController.text);
      await prefs.setString('profile_dob', _dobController.text);
      if (_selectedGender != null) {
        await prefs.setString('profile_gender', _selectedGender!);
      }
      await prefs.setString('profile_contact', _contactController.text);
      await prefs.setString('profile_email', _emailController.text);
      await prefs.setString('profile_bloodGroup', _bloodGroupController.text);
      await prefs.setString('profile_allergies', _allergiesController.text);
      await prefs.setString('profile_conditions', _conditionsController.text);
      await prefs.setString('profile_country_code', _countryCode);

      if (_profileImage != null) {
        await prefs.setString('profile_image_path', _profileImage!.path);
      }

      final List<Map<String, dynamic>> guardiansJson =
          _guardianContacts.map((contact) => contact.toJson()).toList();
      await prefs.setString('profile_guardians', jsonEncode(guardiansJson));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile Saved Successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all mandatory fields marked with *'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // --- Other helper methods ---
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (bc) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('From Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                }),
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('From Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1920),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(() => _dobController.text = DateFormat.yMMMMd().format(picked));
    }
  }

  void _addGuardianContact() {
    setState(() => _guardianContacts.add(GuardianContact()));
  }

  void _removeGuardianContact(GuardianContact contact) {
    setState(() {
      contact.dispose();
      _guardianContacts.remove(contact);
    });
  }

  void _showCustomerCareDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Customer Care'),
              content: const Text('How would you like to contact us?'),
              actions: [
                TextButton.icon(
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Us'),
                    onPressed: () {
                      launchUrl(Uri(scheme: 'tel', path: '+1-234-567-8900'));
                      Navigator.of(context).pop();
                    }),
                TextButton.icon(
                    icon: const Icon(Icons.email),
                    label: const Text('Email Us'),
                    onPressed: () {
                      launchUrl(Uri(
                          scheme: 'mailto',
                          path: 'support@nurocare.com',
                          query: 'subject=App Support Request'));
                      Navigator.of(context).pop();
                    }),
              ],
            ));
  }

  // --- MAIN BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap:
                _showImagePickerOptions, // Let user tap the avatar to change it
            child: CircleAvatar(
              radius: 22,
              backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
              backgroundColor: Colors.white70,
              child: _profileImage == null
                  ? const Icon(Icons.person, size: 28, color: Colors.blueAccent)
                  : null,
            ),
          ),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color(0xFF76E8E8),
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.grey),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Settings', // Provides a label on long-press
          ),
          const SizedBox(width: 8), // Add some padding to the edge
        ],
      ),
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
                  Colors.white.withAlpha(450),
                ])),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        20,
                    left: 16,
                    right: 16,
                    bottom: 16),
                children: <Widget>[
                  // --- User Avatar Section ---
                  Center(
                      child: Stack(children: [
                    CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        backgroundColor: const Color(0xFFC4FDFD),
                        child: _profileImage == null
                            ? const Icon(Icons.person,
                                size: 70, color: Colors.blueAccent)
                            : null),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.white),
                                onPressed: _showImagePickerOptions)))
                  ])),
                  const SizedBox(height: 24),

                  // --- Form Sections ---
                  _buildSectionTitle('Personal Information'),
                  _buildTextFormField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      isMandatory: true),
                  _buildDateField(isMandatory: true),
                  _buildSectionTitle('Gender', isMandatory: true),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12)),
                      child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildGenderRadio('Male', Icons.male),
                            _buildGenderRadio('Female', Icons.female),
                            _buildGenderRadio('Other', Icons.question_mark)
                          ])),
                  const SizedBox(height: 16),
                  _buildContactField(isMandatory: true),
                  _buildTextFormField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email,
                      isMandatory: true,
                      keyboardType: TextInputType.emailAddress),

                  const Divider(height: 40, color: Colors.white24),
                  _buildSectionTitle('Medical Information'),
                  _buildTextFormField(
                      controller: _bloodGroupController,
                      label: 'Blood Group',
                      icon: Icons.bloodtype,
                      isMandatory: true),
                  _buildTextFormField(
                      controller: _allergiesController,
                      label: 'Known Allergies (Optional)',
                      icon: Icons.monitor_heart),
                  _buildTextFormField(
                      controller: _conditionsController,
                      label: 'Chronic Conditions (Optional)',
                      icon: Icons.medical_services),

                  const Divider(height: 40, color: Colors.white24),
                  _buildSectionTitle('Guardian Contacts (Optional)'),
                  Column(children: [
                    for (final contact in _guardianContacts)
                      _buildGuardianContactField(contact)
                  ]),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                      onPressed: _addGuardianContact,
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.blueAccent),
                      label: const Text('Add Guardian Contact',
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12))),

                  const SizedBox(height: 40),
                  // --- Save Button is now here, before settings ---
                  ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Profile'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold))),

                  const Divider(height: 40, color: Colors.white24),
                  // --- Settings are at the very bottom ---
                  _buildSectionTitle('Settings & Support'),
                  _buildSettingsTile(
                      title: 'Customer Care',
                      icon: Icons.support_agent_outlined,
                      onTap: _showCustomerCareDialog),
                  _buildSettingsTile(
                      title: 'App Info',
                      icon: Icons.info_outline,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AppInfoScreen()))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildSectionTitle(String title, {bool isMandatory = false}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
        child: RichText(
            text: TextSpan(
                text: title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
                children: isMandatory
                    ? [
                        const TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red, fontSize: 18))
                      ]
                    : [])));
  }

  Widget _buildDateField({bool isMandatory = false}) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: InputDecoration(
                label: _buildMandatoryLabel('Date of Birth', isMandatory),
                prefixIcon: const Icon(Icons.cake, color: Colors.blueAccent),
                suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month_outlined,
                        color: Colors.blueAccent),
                    onPressed: () => _selectDate(context)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9)),
            onTap: () => _selectDate(context)));
  }

  Widget _buildContactField({bool isMandatory = false}) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
            controller: _contactController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                label: _buildMandatoryLabel('Contact Number', isMandatory),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                prefixIcon: CountryCodePicker(
                    onChanged: (country) {
                      setState(() => _countryCode = country.dialCode ?? '+91');
                    },
                    initialSelection: 'IN',
                    favorite: const ['+91', 'IN'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    textStyle: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold)))));
  }

  Widget _buildMandatoryLabel(String title, bool isMandatory) {
    return RichText(
        text: TextSpan(
            text: title,
            style: TextStyle(color: Colors.grey[600]),
            children: isMandatory
                ? [
                    const TextSpan(
                        text: ' *', style: TextStyle(color: Colors.red))
                  ]
                : []));
  }

  Widget _buildSettingsTile(
      {required String title,
      required IconData icon,
      required VoidCallback onTap,
      Color? color}) {
    return Card(
        color: Colors.white.withOpacity(0.9),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: ListTile(
            leading: Icon(icon, color: color ?? Colors.blueAccent),
            title: Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
            onTap: onTap));
  }

  Widget _buildGenderRadio(String title, IconData icon) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Radio<String>(
          value: title,
          groupValue: _selectedGender,
          onChanged: (String? value) => setState(() => _selectedGender = value),
          activeColor: Colors.blueAccent,
          visualDensity: VisualDensity.compact),
      Icon(icon,
          color: _selectedGender == title ? Colors.blueAccent : Colors.grey),
      const SizedBox(width: 4),
      Text(title, style: TextStyle(color: Colors.grey[800]))
    ]);
  }

  Widget _buildTextFormField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isMandatory = false,
      TextInputType? keyboardType}) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                label: _buildMandatoryLabel(label, isMandatory),
                prefixIcon: Icon(icon, color: Colors.blueAccent),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9))));
  }

  Widget _buildGuardianContactField(GuardianContact contact) {
    return Padding(
        key: ValueKey(contact.id),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: TextFormField(
                  controller: contact.nameController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                      labelText: 'Guardian Name',
                      prefixIcon: const Icon(Icons.shield_outlined,
                          color: Colors.blueAccent),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9)))),
          const SizedBox(width: 8),
          Expanded(
              child: TextFormField(
                  controller: contact.numberController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                      labelText: 'Guardian Number',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      prefixIcon: CountryCodePicker(
                          onChanged: (country) {
                            setState(() => contact.countryCode =
                                country.dialCode ?? '+91');
                          },
                          initialSelection: 'IN',
                          favorite: const ['+91', 'IN'],
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          textStyle: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold))))),
          IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red[400]),
              onPressed: () => _removeGuardianContact(contact))
        ]));
  }
}
