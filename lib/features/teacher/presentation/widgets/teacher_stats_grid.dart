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
    this.totalStudents = 0,
    this.activeBatches = 0,
    this.pendingReviews = 0,
    this.avgAttendance = 100.0,
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
                trend: totalStudents > 0 ? '$totalStudents Registered' : 'No Students Yet',
                isPositiveTrend: totalStudents > 0,
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
                trend: '$activeBatches Active',
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
                trend: pendingReviews > 0 ? 'Requires Action' : 'All Clear',
                isPositiveTrend: pendingReviews == 0,
                onTap: onReviewsTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.verified_rounded,
                iconColor: AppColors.success,
                value: totalStudents > 0 ? '${avgAttendance.toStringAsFixed(1)}%' : 'N/A',
                label: 'Avg Attendance',
                trend: totalStudents > 0
                    ? (avgAttendance >= 85 ? 'High engagement' : 'Follow-up needed')
                    : 'No attendance data',
                isPositiveTrend: avgAttendance >= 85,
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 19),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isPositiveTrend
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
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
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
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
