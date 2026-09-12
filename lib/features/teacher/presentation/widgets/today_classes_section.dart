import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ClassScheduleItem {
  final String classId;
  final String className;
  final String standardBadge;
  final String subject;
  final String time;
  final String room;
  final int studentCount;
  final String status; // 'completed', 'live', 'upcoming'
  final Color badgeColor;

  const ClassScheduleItem({
    required this.classId,
    required this.className,
    required this.standardBadge,
    required this.subject,
    required this.time,
    required this.room,
    required this.studentCount,
    required this.status,
    required this.badgeColor,
  });
}

class TodayClassesSection extends StatelessWidget {
  final List<ClassScheduleItem> classes;
  final ValueChanged<ClassScheduleItem>? onTakeAttendance;
  final ValueChanged<ClassScheduleItem>? onViewRoster;
  final ValueChanged<ClassScheduleItem>? onJoinLiveStage;

  const TodayClassesSection({
    super.key,
    required this.classes,
    this.onTakeAttendance,
    this.onViewRoster,
    this.onJoinLiveStage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Teaching Schedule",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${classes.length} Sessions',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...classes.map((cls) => _ClassScheduleCard(
              item: cls,
              onTakeAttendance: () => onTakeAttendance?.call(cls),
              onViewRoster: () => onViewRoster?.call(cls),
              onJoinLiveStage: () => onJoinLiveStage?.call(cls),
            )),
      ],
    );
  }
}

class _ClassScheduleCard extends StatelessWidget {
  final ClassScheduleItem item;
  final VoidCallback onTakeAttendance;
  final VoidCallback onViewRoster;
  final VoidCallback? onJoinLiveStage;

  const _ClassScheduleCard({
    required this.item,
    required this.onTakeAttendance,
    required this.onViewRoster,
    this.onJoinLiveStage,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = item.status == 'live';
    final isCompleted = item.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLive
              ? AppColors.primary
              : AppColors.border,
          width: isLive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Standard tag + Status chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.standardBadge,
                  style: TextStyle(
                    color: item.badgeColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.className,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(item.status),
            ],
          ),

          const SizedBox(height: 10),

          // Subject & Topic
          Text(
            item.subject,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          // Time, Room & Students
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                item.time,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                item.room,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.people_outline_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.studentCount} Students',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (isLive) ...[
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: onJoinLiveStage,
                icon: const Icon(Icons.videocam_rounded, size: 18),
                label: const Text(
                  'Enter Live Broadcast Stage',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Actions row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewRoster,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.people_alt_rounded, size: 16),
                  label: const Text(
                    'Class Roster',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onTakeAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted
                        ? AppColors.surfaceLight
                        : AppColors.primary,
                    foregroundColor: isCompleted
                        ? AppColors.textSecondary
                        : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle_outline_rounded
                        : Icons.fact_check_rounded,
                    size: 16,
                  ),
                  label: Text(
                    isCompleted ? 'Attendance Marked' : 'Attendance',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'live':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'LIVE NOW',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      case 'completed':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Completed',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Upcoming',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }
}
