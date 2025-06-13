import 'package:flutter/material.dart';
import 'package:emonic/constants/colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildHelpSection(
            title: 'FAQs',
            icon: Icons.question_answer_outlined,
          ),
          _buildHelpSection(
            title: 'Contact Support',
            icon: Icons.email_outlined,
          ),
          _buildHelpSection(
            title: 'User Guide',
            icon: Icons.book_outlined,
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need immediate assistance?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Our support team is available 24/7 to help you with any issues or questions you may have.',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection({
    required String title,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
        onTap: () {},
      ),
    );
  }
}
