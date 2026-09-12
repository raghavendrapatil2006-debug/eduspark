import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class TeacherCertificateSheet extends StatelessWidget {
  final String teacherName;
  final int completedModules;
  final int totalModules;

  const TeacherCertificateSheet({
    super.key,
    required this.teacherName,
    required this.completedModules,
    required this.totalModules,
  });

  @override
  Widget build(BuildContext context) {
    final isCertified = completedModules >= totalModules;

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
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Teacher Professional Certificate',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.border, height: 16),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  // Certificate Diploma Frame
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isCertified
                            ? AppColors.secondary
                            : AppColors.border,
                        width: 2,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surface,
                          isCertified
                              ? AppColors.secondary.withValues(alpha: 0.08)
                              : AppColors.surfaceLight,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Laurel Gold Icon
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: isCertified
                                ? AppColors.secondary.withValues(alpha: 0.15)
                                : AppColors.surfaceLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCertified
                                ? Icons.workspace_premium_rounded
                                : Icons.lock_outline_rounded,
                            color: isCertified
                                ? AppColors.secondary
                                : AppColors.textMuted,
                            size: 38,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          isCertified
                              ? 'CERTIFICATE OF EXCELLENCE'
                              : 'CERTIFICATION IN PROGRESS',
                          style: TextStyle(
                            color: isCertified
                                ? AppColors.secondary
                                : AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'EduSpark Certified AI Educator',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'This is proudly presented to',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          teacherName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'For demonstrating professional mastery in standard-adaptive classroom pedagogy, generative AI lesson design, dynamic formative assessment, and proactive student intervention strategies across Kindergarten to University levels.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Divider(color: AppColors.border),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ISSUED BY',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'EduSpark Pedagogy Board',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'CREDENTIAL ID',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isCertified ? 'EDU-AI-2026-9842' : 'Pending Completion',
                                  style: TextStyle(
                                    color: isCertified ? AppColors.secondary : AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Progress breakdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircularProgressIndicator(
                          value: completedModules / totalModules,
                          backgroundColor: AppColors.surfaceLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCertified ? AppColors.success : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$completedModules of $totalModules Modules Finished',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isCertified
                                    ? 'All certification requirements satisfied!'
                                    : 'Complete the remaining modules to unlock your verified credential.',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isCertified)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Certificate downloaded to your device!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text(
                          'Download Verified Certificate',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
