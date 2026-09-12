import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../core/services/user_profile_service.dart';

class StudentIdVerificationSheet extends StatefulWidget {
  final VoidCallback? onVerified;

  const StudentIdVerificationSheet({super.key, this.onVerified});

  @override
  State<StudentIdVerificationSheet> createState() =>
      _StudentIdVerificationSheetState();
}

class _StudentIdVerificationSheetState extends State<StudentIdVerificationSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _institutionController;
  late final TextEditingController _studentNameController;
  late final TextEditingController _rollNoController;

  bool _isIdCardUploaded = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _studentNameController = TextEditingController(
      text: user?.name ?? UserProfileService.instance.studentName,
    );
    _institutionController = TextEditingController(
      text: user?.school ?? UserProfileService.instance.school,
    );
    _rollNoController = TextEditingController(text: '2024-CSE-108');
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _studentNameController.dispose();
    _rollNoController.dispose();
    super.dispose();
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);

    // Simulate instant AI credentials scan
    await Future.delayed(const Duration(milliseconds: 1200));

    await SubscriptionService.instance.submitStudentVerification(
      institutionName: _institutionController.text.trim(),
      studentName: _studentNameController.text.trim(),
      rollNumber: _rollNoController.text.trim(),
      idCardImagePath: 'simulated_student_id_card.png',
    );

    if (!mounted) return;
    setState(() => _isVerifying = false);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🎓 Student ID verified! 50% discount unlocked (₹99/mo applied).',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    widget.onVerified?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.badge_rounded,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student ID Verification',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Unlock 50% discount • Valid for all school & college students',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.border, height: 24),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Discount highlight banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: AppColors.secondary,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Special Student Price: ₹99/month (Regular ₹199/mo). Verified once, valid across your entire academic year!',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'School / College / University Name',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _institutionController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Delhi Public School / IIT Bombay',
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surface,
                            prefixIcon: const Icon(
                              Icons.school_rounded,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Please enter your institution' : null,
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Student Full Name (As per ID Card)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _studentNameController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Your name on school ID',
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surface,
                            prefixIcon: const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Student Roll Number / Enrollment ID',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _rollNoController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. 2024-CSE-108 or Roll 18',
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surface,
                            prefixIcon: const Icon(
                              Icons.numbers_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Please enter roll number' : null,
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Student ID Card Document',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ID Card Upload Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isIdCardUploaded
                                  ? AppColors.success.withValues(alpha: 0.5)
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _isIdCardUploaded
                                      ? AppColors.success.withValues(alpha: 0.15)
                                      : AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _isIdCardUploaded
                                      ? Icons.check_circle_rounded
                                      : Icons.cloud_upload_rounded,
                                  color: _isIdCardUploaded
                                      ? AppColors.success
                                      : AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isIdCardUploaded
                                          ? 'Student_ID_Card_Document.jpg'
                                          : 'Upload School/College ID Photo',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _isIdCardUploaded
                                          ? 'Valid Student ID Card Detected • Ready for AI verification'
                                          : 'Supported: JPG, PNG, PDF (Max 10MB)',
                                      style: TextStyle(
                                        color: _isIdCardUploaded
                                          ? AppColors.success
                                          : AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isIdCardUploaded = !_isIdCardUploaded;
                                  });
                                },
                                child: Text(
                                  _isIdCardUploaded ? 'Change' : 'Upload',
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom Submit Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Validating Student Credentials...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_user_rounded, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Verify & Unlock ₹99/mo Student Plan',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
