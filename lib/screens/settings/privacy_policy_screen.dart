import 'package:flutter/material.dart';
import 'package:emonic/constants/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy for EMONIC',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Data Collection',
              'We collect the following information:\n'
                  '• Energy consumption data\n'
                  '• User profile information\n'
                  '• Device information\n'
                  '• Usage statistics',
            ),
            _buildSection(
              'How We Use Your Data',
              'Your data is used to:\n'
                  '• Monitor and analyze energy consumption\n'
                  '• Provide personalized recommendations\n'
                  '• Improve our services\n'
                  '• Send important notifications',
            ),
            _buildSection(
              'Data Security',
              'We implement security measures to protect your personal information. '
                  'Your data is encrypted and stored securely on our servers.',
            ),
            _buildSection(
              'Third-Party Services',
              'We may use third-party services to:\n'
                  '• Process payments\n'
                  '• Analyze app usage\n'
                  '• Send notifications',
            ),
            _buildSection(
              'Your Rights',
              'You have the right to:\n'
                  '• Access your personal data\n'
                  '• Request data deletion\n'
                  '• Opt-out of data collection\n'
                  '• Update your information',
            ),
            _buildSection(
              'Contact Us',
              'If you have questions about this privacy policy, please contact us at:\n'
                  'support@emonic.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
