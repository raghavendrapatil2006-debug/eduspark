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
              "Today's Schedule",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
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
        const SizedBox(height: 12),
        if (classes.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'No classes scheduled for today.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? AppColors.primary.withValues(alpha: 0.6) : AppColors.border,
          width: isLive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Standard tag + Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: item.badgeColor.withValues(alpha: 0.14),
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
              Expanded(
                child: Text(
                  item.className,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(item.status),
            ],
          ),

          const SizedBox(height: 8),

          // Subject name
          Text(
            item.subject,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Time, Room, and Students count
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 13.5,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                item.time,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.location_on_outlined,
                size: 13.5,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                item.room,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.people_outline_rounded,
                size: 13.5,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.studentCount} Students',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Actions row
          Row(
            children: [
              if (isLive) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onJoinLiveStage,
                    icon: const Icon(Icons.videocam_rounded, size: 16),
                    label: const Text(
                      'Join Live Stage',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else ...[
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: Icon(
                      isCompleted
                          ? Icons.check_circle_outline_rounded
                          : Icons.checklist_rounded,
                      size: 15,
                    ),
                    label: Text(
                      isCompleted ? 'Attendance Marked' : 'Take Attendance',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              OutlinedButton.icon(
                onPressed: onViewRoster,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.badge_outlined, size: 14),
                label: const Text(
                  'Roster',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 3, backgroundColor: Color(0xFFEF4444)),
              SizedBox(width: 4),
              Text(
                'LIVE NOW',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        );
      case 'completed':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Completed',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Upcoming',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }
}
