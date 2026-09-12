import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class TeacherStatsGrid extends StatelessWidget {
  final int totalStudents;
  final int activeBatches;
  final int pendingReviews;
  final double avgAttendance;
  final VoidCallback? onStudentsTap;
  final VoidCallback? onBatchesTap;
  final VoidCallback? onReviewsTap;
  final VoidCallback? onAttendanceTap;

  const TeacherStatsGrid({
    super.key,
    this.totalStudents = 148,
    this.activeBatches = 4,
    this.pendingReviews = 6,
    this.avgAttendance = 94.2,
    this.onStudentsTap,
    this.onBatchesTap,
    this.onReviewsTap,
    this.onAttendanceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.groups_rounded,
                iconColor: AppColors.primary,
                value: '$totalStudents',
                label: 'Total Students',
                trend: '+12 this term',
                isPositiveTrend: true,
                onTap: onStudentsTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.meeting_room_rounded,
                iconColor: const Color(0xFF818CF8),
                value: '$activeBatches',
                label: 'Active Batches',
                trend: 'KG to PhD',
                isPositiveTrend: true,
                onTap: onBatchesTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.assignment_late_rounded,
                iconColor: AppColors.secondary,
                value: '$pendingReviews',
                label: 'Pending Reviews',
                trend: 'Due today',
                isPositiveTrend: false,
                onTap: onReviewsTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.verified_rounded,
                iconColor: AppColors.success,
                value: '${avgAttendance.toStringAsFixed(1)}%',
                label: 'Avg Attendance',
                trend: 'High engagement',
                isPositiveTrend: true,
                onTap: onAttendanceTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.trend,
    required this.isPositiveTrend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isPositiveTrend
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        color: isPositiveTrend
                            ? AppColors.success
                            : AppColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
