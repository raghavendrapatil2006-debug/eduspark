import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/online_class_service.dart';
import 'schedule_online_class_sheet.dart';

class OnlineClassesHubSheet extends StatefulWidget {
  const OnlineClassesHubSheet({super.key});

  @override
  State<OnlineClassesHubSheet> createState() => _OnlineClassesHubSheetState();
}

class _OnlineClassesHubSheetState extends State<OnlineClassesHubSheet> {
  @override
  void initState() {
    super.initState();
    OnlineClassService.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    OnlineClassService.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _openScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ScheduleOnlineClassSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final live = OnlineClassService.instance.liveSessions;
    final upcoming = OnlineClassService.instance.upcomingSessions;
    final completed = OnlineClassService.instance.completedSessions;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Sheet Notch
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Virtual Classroom Hub',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Host interactive online classes & AI note-taking',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Main List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                children: [
                  // Schedule or Instant Class Action Card
                  _buildQuickActionBanner(),

                  const SizedBox(height: 22),

                  // Section 1: Active Live Class
                  if (live.isNotEmpty) ...[
                    _sectionHeader(
                      'Broadcast Stage • Live Right Now',
                      Icons.sensors_rounded,
                      AppColors.danger,
                    ),
                    ...live.map((s) => _buildLiveClassCard(s)),
                    const SizedBox(height: 20),
                  ],

                  // Section 2: Scheduled Upcoming Classes
                  _sectionHeader(
                    'Scheduled Online Classes (${upcoming.length})',
                    Icons.event_available_rounded,
                    AppColors.primary,
                  ),
                  if (upcoming.isEmpty)
                    _buildEmptyState('No upcoming sessions scheduled')
                  else
                    ...upcoming.map((s) => _buildUpcomingClassCard(s)),

                  const SizedBox(height: 20),

                  // Section 3: Completed Lecture Recordings
                  _sectionHeader(
                    'Past Recordings & AI Notes (${completed.length})',
                    Icons.history_edu_rounded,
                    AppColors.secondary,
                  ),
                  ...completed.map((s) => _buildCompletedClassCard(s)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUICK ACTION BANNER
  // ============================================================
  Widget _buildQuickActionBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Launch Virtual Classroom',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Live whiteboard, student Q&A queue, and automated AI summary notes.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _openScheduleSheet,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('New Class'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LIVE CLASS CARD
  // ============================================================
  Widget _buildLiveClassCard(OnlineClassSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: AppColors.danger),
                    SizedBox(width: 5),
                    Text(
                      'LIVE BROADCAST',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                session.targetStandard,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.people_alt, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${session.activeStudentCount} Joined',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            session.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                session.scheduledTime,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.link_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                session.roomCode,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push('/teacher/live-class', extra: session);
              },
              icon: const Icon(Icons.meeting_room_rounded, size: 18),
              label: const Text(
                'Enter Broadcast Stage',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
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
        ],
      ),
    );
  }

  // ============================================================
  // UPCOMING CLASS CARD
  // ============================================================
  Widget _buildUpcomingClassCard(OnlineClassSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  session.targetStandard,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  session.platform,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            session.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                session.scheduledTime,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              Text(
                'Room: ${session.roomCode}',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Class link copied: ${session.meetingLink}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 15),
                  label: const Text('Share Link', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    OnlineClassService.instance.startLiveClass(session.id);
                    Navigator.pop(context);
                    context.push('/teacher/live-class', extra: session);
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: const Text('Start Early', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPLETED CLASS CARD
  // ============================================================
  Widget _buildCompletedClassCard(OnlineClassSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'COMPLETED',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                session.targetStandard,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            session.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            session.scheduledTime,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          if (session.aiNotesSummary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${session.aiNotesSummary.length} AI Lecture Notes Generated & Distributed',
              style: const TextStyle(
                color: Color(0xFF818CF8),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ),
    );
  }
}
