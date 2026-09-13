import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/teacher_header.dart';
import '../widgets/teacher_stats_grid.dart';
import '../widgets/teacher_quick_actions.dart';
import '../widgets/today_classes_section.dart';
import '../widgets/at_risk_students_card.dart';
import '../widgets/ai_lesson_planner_sheet.dart';
import '../widgets/ai_question_paper_sheet.dart';
import '../widgets/create_assignment_sheet.dart';
import '../widgets/teacher_class_roster_sheet.dart';
import '../widgets/teacher_announcements_sheet.dart';
import '../../../../core/services/online_class_service.dart';
import '../../../../core/services/teacher_curriculum_service.dart';
import '../widgets/online_classes_hub_sheet.dart';
import '../widgets/teacher_standard_picker_sheet.dart';
import 'live_classroom_stage_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _currentIndex = 0;
  final String _teacherName = 'Prof. Raghavendra';
  final int _unreadNotifications = 3;

  List<ClassScheduleItem> _classes = [];
  List<AtRiskStudent> _atRiskStudents = [];
  List<Map<String, dynamic>> _homeworkList = [];
  List<Map<String, dynamic>> _pendingGrading = [];

  @override
  void initState() {
    super.initState();
    _loadAdaptiveData();
    TeacherCurriculumService.instance.addListener(_onCurriculumChanged);
    TeacherCurriculumService.instance.init();
  }

  @override
  void dispose() {
    TeacherCurriculumService.instance.removeListener(_onCurriculumChanged);
    super.dispose();
  }

  void _onCurriculumChanged() {
    if (mounted) {
      setState(() {
        _loadAdaptiveData();
      });
    }
  }

  void _loadAdaptiveData() {
    final cur = TeacherCurriculumService.instance;
    _classes = List.from(cur.getAdaptiveSchedule());
    _atRiskStudents = List.from(cur.getAdaptiveAtRiskStudents());
    _homeworkList = List.from(cur.getAdaptiveHomeworkList());
    _pendingGrading = List.from(cur.getAdaptivePendingGrading());
  }

  // Action Modals
  void _openAttendance(ClassScheduleItem cls) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TeacherClassRosterSheet(
        className: cls.className,
        standardBadge: cls.standardBadge,
      ),
    );
  }

  void _openRoster(ClassScheduleItem cls) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TeacherClassRosterSheet(
        className: cls.className,
        standardBadge: cls.standardBadge,
      ),
    );
  }

  void _openAiLessonPlanner() {
    final cur = TeacherCurriculumService.instance;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiLessonPlannerSheet(
        initialStandard: cur.activeBranch,
        initialSubject: cur.activeSubject,
      ),
    );
  }

  void _openAiExamGenerator() {
    final cur = TeacherCurriculumService.instance;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiQuestionPaperSheet(
        initialStandard: cur.activeBranch,
        initialSubject: cur.activeSubject,
      ),
    );
  }

  void _openCreateAssignment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateAssignmentSheet(
        onAssignmentCreated: (draft) {
          setState(() {
            _homeworkList.insert(0, {
              'title': draft.title,
              'class': draft.targetClass,
              'subject': draft.subject,
              'due': draft.dueDate,
              'submitted': 0,
              'total': 38,
              'status': 'Active',
              'points': draft.maxPoints,
            });
          });
        },
      ),
    );
  }

  void _openAnnouncements() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TeacherAnnouncementsSheet(),
    );
  }

  void _openOnlineClassesHub() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const OnlineClassesHubSheet(),
    );
  }

  void _openLiveClass([ClassScheduleItem? cls]) {
    final liveSession = OnlineClassService.instance.currentLiveSession;
    if (liveSession != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LiveClassroomStageScreen(session: liveSession),
        ),
      );
    } else {
      _openOnlineClassesHub();
    }
  }

  void _gradeSubmission(Map<String, dynamic> submission) {
    final gradeController = TextEditingController(text: '95');
    final feedbackController = TextEditingController(
      text: 'Excellent conceptual grasp and step-by-step working! Keep it up.',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.grading_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Grade ${submission['student']}',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 17),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${submission['assignment']} • ${submission['class']}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Gemini AI Pre-evaluation: ${submission['autoScore']}',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Final Marks (/100):',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: gradeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Teacher Feedback:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: feedbackController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _pendingGrading.remove(submission);
                });
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Graded ${submission['student']} (${gradeController.text}/100)! Feedback sent.',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Submit & Return'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildOverviewTab(),
            _buildClassesTab(),
            _buildAiSuiteTab(),
            _buildAssignmentsTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.18),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.groups_rounded, color: AppColors.primary),
              label: 'My Classes',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppColors.secondary),
              label: 'AI Suite',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.assignment_rounded, color: AppColors.primary),
              label: 'Assignments',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAB 0: DASHBOARD / OVERVIEW
  // ============================================================
  Widget _buildOverviewTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Teacher Header
              TeacherHeader(
                teacherName: _teacherName,
                unreadNotifications: _unreadNotifications,
                onNotificationTap: _openAnnouncements,
              ),

              const SizedBox(height: 22),

              // Stats Grid
              TeacherStatsGrid(
                totalStudents: 148,
                activeBatches: _classes.length,
                pendingReviews: _pendingGrading.length,
                avgAttendance: 94.2,
                onBatchesTap: () => setState(() => _currentIndex = 1),
                onReviewsTap: () => setState(() => _currentIndex = 3),
              ),

              const SizedBox(height: 22),

              // Teacher Quick Actions
              TeacherQuickActions(
                onOnlineClass: _openOnlineClassesHub,
                onCreateAssignment: _openCreateAssignment,
                onAiExamGenerator: _openAiExamGenerator,
                onAiLessonPlan: _openAiLessonPlanner,
                onBroadcast: _openAnnouncements,
              ),

              const SizedBox(height: 26),

              // Today's Classes & Schedule
              TodayClassesSection(
                classes: _classes,
                onTakeAttendance: _openAttendance,
                onViewRoster: _openRoster,
                onJoinLiveStage: (cls) => _openLiveClass(cls),
              ),

              const SizedBox(height: 22),

              // AI Attention Alerts (At-Risk Students)
              AtRiskStudentsCard(
                students: _atRiskStudents,
                onAssignPractice: (st) {
                  _openCreateAssignment();
                },
                onSendNote: (st) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Encouragement note sent to ${st.name}!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Quick Grading Queue
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Submissions to Grade',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_pendingGrading.length} Due',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_pendingGrading.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 36),
                        SizedBox(height: 8),
                        Text(
                          'All caught up! No submissions awaiting grading.',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._pendingGrading.map((sub) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: Text(
                              sub['student'][0],
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub['student'],
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${sub['assignment']} • ${sub['class']}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  sub['autoScore'],
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _gradeSubmission(sub),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Review',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    )),
            ]),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TAB 1: MY CLASSES / BATCHES
  // ============================================================
  Widget _buildClassesTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Classes & Batches',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_classes.length} Active Batches • ${TeacherCurriculumService.instance.activeBranch}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Switch Teaching Focus',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const TeacherStandardPickerSheet(),
                );
              },
              icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
            ),
          ],
        ),

        const SizedBox(height: 18),

        ..._classes.map((cls) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: cls.badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cls.standardBadge,
                          style: TextStyle(
                            color: cls.badgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cls.className,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 18),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    cls.subject,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.people_alt_rounded, size: 15, color: AppColors.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        '${cls.studentCount} Students Enrolled',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.schedule_rounded, size: 15, color: AppColors.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        cls.time,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openRoster(cls),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.badge_rounded, size: 16),
                          label: const Text(
                            'Student Roster',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openAttendance(cls),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.checklist_rounded, size: 16),
                          label: const Text(
                            'Take Attendance',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ============================================================
  // TAB 2: AI TEACHING SUITE
  // ============================================================
  Widget _buildAiSuiteTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        // AI Suite Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4F8EF7).withValues(alpha: 0.25),
                const Color(0xFF818CF8).withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EduSpark AI for Educators',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Smart generative tools to save hours of prep time',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // Tool 1: AI Lesson Planner
        _aiToolCard(
          icon: Icons.lightbulb_rounded,
          iconColor: const Color(0xFF818CF8),
          title: 'AI Lesson Planner',
          subtitle:
              'Generate a structured 45-minute lesson plan with learning objectives, hooks, whiteboard illustrations, student activities, and exit checks.',
          badge: 'Curriculum Builder',
          actionText: 'Launch Lesson Planner',
          onTap: _openAiLessonPlanner,
        ),

        const SizedBox(height: 14),

        // Tool 2: AI Exam Maker
        _aiToolCard(
          icon: Icons.quiz_rounded,
          iconColor: AppColors.secondary,
          title: 'AI Exam & Paper Maker',
          subtitle:
              'Craft balanced test papers with Section A/B/C, marking schemes, and complete teacher answer keys for any grade level from KG to PhD.',
          badge: 'Assessment Specialist',
          actionText: 'Create Exam Paper',
          onTap: _openAiExamGenerator,
        ),

        const SizedBox(height: 14),

        // Tool 3: AI Student Attention Radar
        _aiToolCard(
          icon: Icons.psychology_alt_rounded,
          iconColor: AppColors.success,
          title: 'Student Attention Radar',
          subtitle:
              'Identifies students who are struggling with specific topics based on recent quiz scores and doubt patterns, with 1-tap intervention drills.',
          badge: 'Student Analytics',
          actionText: 'Inspect Flags & Alerts',
          onTap: () {
            setState(() => _currentIndex = 0);
          },
        ),

        const SizedBox(height: 14),

        // Tool 4: Class Broadcast Manager
        _aiToolCard(
          icon: Icons.campaign_rounded,
          iconColor: AppColors.primary,
          title: 'Class Noticeboard & Broadcasts',
          subtitle:
              'Post homework updates, exam notices, and important alerts directly to specific student batches with custom priority tags.',
          badge: 'Class Communication',
          actionText: 'Compose Announcement',
          onTap: _openAnnouncements,
        ),

        const SizedBox(height: 14),

        // Tool 5: Virtual Classroom Stage & Live AI Notes
        _aiToolCard(
          icon: Icons.videocam_rounded,
          iconColor: const Color(0xFFEF4444),
          title: 'Virtual Classroom Stage & Live Notes',
          subtitle:
              'Host interactive online classes with digital whiteboard, real-time student doubts queue, in-class pop quizzes, and automated Gemini AI lecture note transcription.',
          badge: 'Live Virtual Instruction',
          actionText: 'Open Virtual Classroom Hub',
          onTap: _openOnlineClassesHub,
        ),
      ],
    );
  }

  Widget _aiToolCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      badge,
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor.withValues(alpha: 0.15),
                foregroundColor: iconColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: iconColor.withValues(alpha: 0.3)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: Icon(icon, size: 16),
              label: Text(
                actionText,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 3: ASSIGNMENTS & HOMEWORK
  // ============================================================
  Widget _buildAssignmentsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assignments Tracker',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${TeacherCurriculumService.instance.activeBranch} • ${TeacherCurriculumService.instance.activeSubject}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openCreateAssignment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'Assign',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        ..._homeworkList.map((hw) {
          final submitted = hw['submitted'] as int;
          final total = hw['total'] as int;
          final pct = total > 0 ? (submitted / total) : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
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
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hw['class'],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${hw['subject']} • ${hw['points']} XP',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      hw['status'],
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  hw['title'],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${hw['due']}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$submitted/$total Submitted (${(pct * 100).toInt()}%)',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct >= 0.8
                          ? AppColors.success
                          : (pct >= 0.5 ? AppColors.secondary : AppColors.primary),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
