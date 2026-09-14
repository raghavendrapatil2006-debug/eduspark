import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class TeacherQuickActions extends StatelessWidget {
  final VoidCallback onCreateAssignment;
  final VoidCallback onAiExamGenerator;
  final VoidCallback onAiLessonPlan;
  final VoidCallback onBroadcast;
  final VoidCallback? onOnlineClass;

  const TeacherQuickActions({
    super.key,
    required this.onCreateAssignment,
    required this.onAiExamGenerator,
    required this.onAiLessonPlan,
    required this.onBroadcast,
    this.onOnlineClass,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            // On wider screens or standard mobile screens:
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  if (onOnlineClass != null) ...[
                    _ActionChip(
                      icon: Icons.videocam_rounded,
                      color: const Color(0xFFEF4444),
                      label: 'Live Class',
                      badge: 'Live',
                      onTap: onOnlineClass!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  _ActionChip(
                    icon: Icons.post_add_rounded,
                    color: AppColors.primary,
                    label: 'Assign Work',
                    onTap: onCreateAssignment,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.quiz_rounded,
                    color: AppColors.secondary,
                    label: 'AI Exam',
                    onTap: onAiExamGenerator,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.lightbulb_rounded,
                    color: const Color(0xFF818CF8),
                    label: 'Lesson Plan',
                    onTap: onAiLessonPlan,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.campaign_rounded,
                    color: AppColors.success,
                    label: 'Notice',
                    onTap: onBroadcast,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.color,
    required this.label,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
