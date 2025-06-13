import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:emonic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:emonic/screens/settings/privacy_policy_screen.dart';
import 'package:emonic/screens/settings/edit_profile_screen.dart'; // Tambahkan import ini
import 'package:emonic/screens/settings/change_email_screen.dart'; // Add this import
import 'package:emonic/constants/colors.dart'; // Tambahkan import ini
import 'package:emonic/screens/settings/help_screen.dart'; // Add this import
import 'package:emonic/screens/settings/change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // Account Settings Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: 'Change Email',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangeEmailScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          // Other Settings
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Other',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textGrey,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.black),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? AppColors.black),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        title: const Text('Logout'),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text('Are you sure you want to logout?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: AppColors.primaryBlue)),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthenticationBloc>().add(LogoutRequested());
              Navigator.pop(context);
            },
            child: Text('Logout', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
