import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoTile(
            context,
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0', // Example version
          ),
          _buildInfoTile(
            context,
            icon: Icons.update,
            title: 'Last Updated',
            subtitle: 'October 28, 2025', // Example date
          ),
          _buildInfoTile(
            context,
            icon: Icons.business,
            title: 'Presented By',
            subtitle: 'Nuro Care Developers',
          ),
          const Divider(height: 40),
          _buildClickableTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // TODO: Add URL to your Privacy Policy
              print("Privacy Policy tapped");
            },
          ),
          _buildClickableTile(
            context,
            icon: Icons.gavel_outlined,
            title: 'Terms & Conditions',
            onTap: () {
              // TODO: Add URL to your Terms & Conditions
              print("Terms & Conditions tapped");
            },
          ),
        ],
      ),
    );
  }

  // Helper for static info tiles
  Widget _buildInfoTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
    );
  }

  // Helper for clickable tiles
  Widget _buildClickableTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
