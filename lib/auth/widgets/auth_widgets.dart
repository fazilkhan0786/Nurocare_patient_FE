// lib/auth/widgets/auth_widgets.dart
import 'package:country_picker/country_picker.dart'; // NEW: Import the package
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Common Text Field with shadow
class AuthTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF76E8E8),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF76E8E8).withAlpha(400),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}

// UPDATED: Special Text Field for Phone Number with shadow and country picker
class PhoneTextField extends StatefulWidget {
  const PhoneTextField({super.key});

  @override
  State<PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  // Default to India
  Country _selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
  );

  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        // Customize the picker theme
        backgroundColor: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF76E8E8),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF76E8E8).withAlpha(400),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          // This is now a clickable area
          GestureDetector(
            onTap: _openCountryPicker,
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 10),
              color: Colors.transparent, // Make it transparent to catch taps
              child: Row(
                children: [
                  Text(
                    '+${_selectedCountry.phoneCode}', // Display selected code
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 30,
            child: VerticalDivider(
              color: Colors.white54,
              thickness: 1,
            ),
          ),
          const Expanded(
            child: TextField(
              keyboardType: TextInputType.phone,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Enter Phone Number',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Main Auth Button (Login/Signup) with shadow
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const AuthButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2EB5FA).withOpacity(0.6),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2EB5FA),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0, // Elevation is handled by the container's shadow
          ),
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

// Social Login Button (Google/Facebook) with shadow
class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0, // Handled by container
        ),
      ),
    );
  }
}

// Divider with "Or Continue With"
class SocialDivider extends StatelessWidget {
  const SocialDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Or Continue With', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }
}

// -- UPDATED Privacy Policy Text --
class PolicyText extends StatelessWidget {
  const PolicyText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
        children: [
          const WidgetSpan(
            child: Icon(Icons.check_circle, color: Color(0xFF2EB5FA), size: 14),
            alignment: PlaceholderAlignment.middle,
          ),
          const TextSpan(text: ' Continue with '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
                color: Color(0xFF007BFF),
                fontWeight: FontWeight.bold,
                decoration:
                    TextDecoration.underline, // Make it look like a link
                decorationColor: Color(0xFF007BFF)),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Navigate to Privacy Policy Screen
                print('Privacy Policy Tapped');
              },
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'terms of condition',
            style: const TextStyle(
                color: Color(0xFF007BFF),
                fontWeight: FontWeight.bold,
                decoration:
                    TextDecoration.underline, // Make it look like a link
                decorationColor: Color(0xFF007BFF)),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Navigate to Terms and Conditions Screen
                print('Terms of Condition Tapped');
              },
          ),
        ],
      ),
    );
  }
}
