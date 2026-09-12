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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          if (onOnlineClass != null) ...[
            SizedBox(
              width: 86,
              child: _ActionTile(
                icon: Icons.videocam_rounded,
                color: const Color(0xFFEF4444),
                title: 'Go Live',
                subtitle: 'Online Class',
                onTap: onOnlineClass!,
              ),
            ),
            const SizedBox(width: 10),
          ],
          SizedBox(
            width: 86,
            child: _ActionTile(
              icon: Icons.post_add_rounded,
              color: AppColors.primary,
              title: 'Assign',
              subtitle: 'New Work',
              onTap: onCreateAssignment,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 86,
            child: _ActionTile(
              icon: Icons.quiz_rounded,
              color: AppColors.secondary,
              title: 'AI Exam',
              subtitle: 'Make Test',
              onTap: onAiExamGenerator,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 86,
            child: _ActionTile(
              icon: Icons.lightbulb_rounded,
              color: const Color(0xFF818CF8),
              title: 'AI Lesson',
              subtitle: 'Curriculum',
              onTap: onAiLessonPlan,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 86,
            child: _ActionTile(
              icon: Icons.campaign_rounded,
              color: AppColors.success,
              title: 'Broadcast',
              subtitle: 'Notice',
              onTap: onBroadcast,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
