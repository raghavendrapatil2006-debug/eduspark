import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_profile_service.dart';

class SignupScreen extends StatefulWidget {
  final String? initialRole;

  const SignupScreen({super.key, this.initialRole});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _schoolController = TextEditingController();
  final _specializationController = TextEditingController();

  late String _selectedRole;
  String _selectedStandard = 'B.Tech Computer Science & Engineering (CSE)';
  final String _selectedBoard = 'State Technological University';
  bool _obscurePassword = true;
  bool _agreeToTerms = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? 'student';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _schoolController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Color get _accentColor =>
      _selectedRole == 'student' ? AppColors.primary : AppColors.secondary;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'Please accept the Terms of Service to proceed.';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await AuthService.instance.signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
      standard: _selectedRole == 'student' ? _selectedStandard : null,
      board: _selectedRole == 'student' ? _selectedBoard : null,
      school: _schoolController.text.isNotEmpty
          ? _schoolController.text
          : (_selectedRole == 'student'
              ? 'University Institute of Technology'
              : 'Institute of Technology & Advanced Studies'),
      specialization: _selectedRole == 'teacher'
          ? (_specializationController.text.isNotEmpty
              ? _specializationController.text
              : 'Computer Science & Engineering Pedagogy')
          : null,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (res.success) {
      if (_selectedRole == 'teacher') {
        context.go('/teacher-dashboard');
      } else {
        await UserProfileService.instance.updateProfile(
          name: _nameController.text.trim(),
          standard: _selectedStandard,
          school: _schoolController.text.trim().isNotEmpty
              ? _schoolController.text.trim()
              : 'University Institute of Technology',
          board: _selectedBoard,
        );
        if (!mounted) return;
        context.go('/student-home');
      }
    } else {
      setState(() {
        _errorMessage = res.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Create Your Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role Picker Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildRoleTab(
                        label: 'Student Portal',
                        role: 'student',
                        icon: Icons.school_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildRoleTab(
                        label: 'Faculty Studio',
                        role: 'teacher',
                        icon: Icons.cast_for_education_rounded,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Form Container
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.danger,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Full Name
                      _buildFieldLabel('Full Name'),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: _inputDecoration(
                          hint: _selectedRole == 'student'
                              ? 'e.g. Raghavendra'
                              : 'e.g. Prof. Raghavendra',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Please enter your name'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Email Address
                      _buildFieldLabel('Email Address'),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: _inputDecoration(
                          hint: 'your.name@example.com',
                          icon: Icons.email_outlined,
                        ),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Please enter a valid email'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Role-specific fields
                      if (_selectedRole == 'student') ...[
                        _buildFieldLabel('Education Standard / Degree'),
                        _buildStandardDropdown(),

                        const SizedBox(height: 16),

                        _buildFieldLabel('School / College / University'),
                        TextFormField(
                          controller: _schoolController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: _inputDecoration(
                            hint: 'e.g. University Institute of Technology',
                            icon: Icons.account_balance_outlined,
                          ),
                        ),
                      ] else ...[
                        _buildFieldLabel('Teaching Department / Subject'),
                        TextFormField(
                          controller: _specializationController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: _inputDecoration(
                            hint: 'e.g. Science & Physics / Computer Science',
                            icon: Icons.psychology_outlined,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _buildFieldLabel('Institution / School'),
                        TextFormField(
                          controller: _schoolController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: _inputDecoration(
                            hint: 'e.g. Institute of Technology & Advanced Studies',
                            icon: Icons.location_city_outlined,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Password
                      _buildFieldLabel('Password (Min 6 Characters)'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: _inputDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildFieldLabel('Confirm Password'),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: _inputDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_clock_outlined,
                        ),
                        validator: (v) => v != _passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Terms of Service checkbox
                      Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _agreeToTerms,
                              activeColor: _accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              side: const BorderSide(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                              onChanged: (val) {
                                setState(() => _agreeToTerms = val ?? true);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'I agree to EduSpark Terms of Service & Privacy Policy',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _selectedRole == 'student'
                                      ? 'Create Student Account'
                                      : 'Create Educator Account',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab({
    required String label,
    required String role,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
          _errorMessage = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStandardDropdown() {
    final all = UserProfileService.allStandards;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedStandard,
          dropdownColor: AppColors.surface,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: all
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedStandard = val);
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.background,
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _accentColor, width: 1.5),
      ),
    );
  }
}
