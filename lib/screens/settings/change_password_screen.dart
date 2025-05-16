import 'package:flutter/material.dart';
import 'package:emonic/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Add these variables for password validation
  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool containsSpecialChar = false;
  bool contains8Length = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: AppColors.textGrey,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _newPasswordController,
          obscureText: !_showNewPassword,
          decoration: InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _showNewPassword ? Icons.visibility : Icons.visibility_off,
                color: AppColors.textGrey,
              ),
              onPressed: () {
                setState(() {
                  _showNewPassword = !_showNewPassword;
                });
              },
            ),
          ),
          onChanged: (val) {
            if (val == null) return;

            setState(() {
              containsUpperCase = RegExp(r'[A-Z]').hasMatch(val);
              containsLowerCase = RegExp(r'[a-z]').hasMatch(val);
              containsNumber = RegExp(r'[0-9]').hasMatch(val);
              containsSpecialChar =
                  RegExp(r'[!@#$&*~`)\%\-(_+=;:,.<>/?\[\]{}|^]').hasMatch(val);
              contains8Length = val.length >= 8;
            });
          },
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please fill in this field';
            }

            bool isValid = true;
            isValid = isValid && RegExp(r'[A-Z]').hasMatch(val);
            isValid = isValid && RegExp(r'[a-z]').hasMatch(val);
            isValid = isValid && RegExp(r'[0-9]').hasMatch(val);
            isValid = isValid &&
                RegExp(r'[!@#$&*~`)\%\-(_+=;:,.<>/?\[\]{}|^]').hasMatch(val);
            isValid = isValid && val.length >= 8;

            if (!isValid) {
              return 'Please enter a valid password';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "⚈  1 uppercase",
                  style: TextStyle(
                    color: containsUpperCase
                        ? AppColors.green
                        : AppColors.textGrey,
                  ),
                ),
                Text(
                  "⚈  1 lowercase",
                  style: TextStyle(
                    color: containsLowerCase
                        ? AppColors.green
                        : AppColors.textGrey,
                  ),
                ),
                Text(
                  "⚈  1 number",
                  style: TextStyle(
                    color:
                        containsNumber ? AppColors.green : AppColors.textGrey,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "⚈  1 special character",
                  style: TextStyle(
                    color: containsSpecialChar
                        ? AppColors.green
                        : AppColors.textGrey,
                  ),
                ),
                Text(
                  "⚈  8 minimum character",
                  style: TextStyle(
                    color:
                        contains8Length ? AppColors.green : AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userRepo = context.read<UserRepository>();
      await userRepo.updatePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: AppColors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your current password and new password to change your password.',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              // Current password field
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Current Password',
                showPassword: _showCurrentPassword,
                onToggleVisibility: () {
                  setState(() => _showCurrentPassword = !_showCurrentPassword);
                },
              ),
              const SizedBox(height: 16),
              // New password field with validation
              _buildNewPasswordField(),
              const SizedBox(height: 16),
              // Confirm password field
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                showPassword: _showConfirmPassword,
                onToggleVisibility: () {
                  setState(() => _showConfirmPassword = !_showConfirmPassword);
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Change Password',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
