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
import '../../../../core/services/teacher_student_roster_service.dart';
import '../../../../core/services/auth_service.dart';
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
  String get _teacherName {
    final user = AuthService.instance.currentUser;
    if (user != null &&
        user.role == 'teacher' &&
        user.name.trim().isNotEmpty &&
        user.name.trim() != 'Faculty Member') {
      return user.name.trim();
    }
    return 'Guest';
  }

  final int _unreadNotifications = 0;

  List<ClassScheduleItem> _classes = [];
  List<AtRiskStudent> _atRiskStudents = [];
  List<Map<String, dynamic>> _homeworkList = [];
  List<Map<String, dynamic>> _pendingGrading = [];
  int _totalRegisteredStudents = 0;
  double _overallAttendance = 100.0;

  @override
  void initState() {
    super.initState();
    _loadAdaptiveData();
    TeacherCurriculumService.instance.addListener(_onCurriculumChanged);
    TeacherStudentRosterService.instance.addListener(_onRosterChanged);
    AuthService.instance.addListener(_onAuthChanged);
    TeacherCurriculumService.instance.init();
  }

  @override
  void dispose() {
    TeacherCurriculumService.instance.removeListener(_onCurriculumChanged);
    TeacherStudentRosterService.instance.removeListener(_onRosterChanged);
    AuthService.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onRosterChanged() {
    if (mounted) {
      _loadAdaptiveData();
    }
  }

  void _onCurriculumChanged() {
    if (mounted) {
      _loadAdaptiveData();
    }
  }

  Future<void> _loadAdaptiveData() async {
    final cur = TeacherCurriculumService.instance;
    final roster = TeacherStudentRosterService.instance;
    final baseClasses = cur.getAdaptiveSchedule();
    final realClasses = <ClassScheduleItem>[];
    for (final cls in baseClasses) {
      final students = await roster.getStudentsForClass(cls.className);
      realClasses.add(
        ClassScheduleItem(
          classId: cls.classId,
          className: cls.className,
          standardBadge: cls.standardBadge,
          subject: cls.subject,
          time: cls.time,
          room: cls.room,
          studentCount: students.length,
          status: cls.status,
          badgeColor: cls.badgeColor,
        ),
      );
    }
    final atRisk = await roster.getAtRiskStudents();
    final totalCount = await roster.getTotalStudentCount();
    final avgAtt = await roster.getOverallAttendancePercentage();

    if (mounted) {
      setState(() {
        _classes = realClasses;
        _atRiskStudents = atRisk;
        _homeworkList = List.from(cur.getAdaptiveHomeworkList());
        _pendingGrading = List.from(cur.getAdaptivePendingGrading());
        _totalRegisteredStudents = totalCount;
        _overallAttendance = avgAtt;
      });
    }
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.grading_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Review: ${submission['student']}',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${submission['assignment']} • ${submission['class']}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
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
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
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
                      'Graded ${submission['student']} (${gradeController.text}/100)! Feedback recorded.',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save & Return'),
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
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.groups_rounded, color: AppColors.primary),
              label: 'Batches',
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

              const SizedBox(height: 18),

              // Stats Grid
              TeacherStatsGrid(
                totalStudents: _totalRegisteredStudents,
                activeBatches: _classes.length,
                pendingReviews: _pendingGrading.length,
                avgAttendance: _overallAttendance,
                onBatchesTap: () => setState(() => _currentIndex = 1),
                onReviewsTap: () => setState(() => _currentIndex = 3),
              ),

              const SizedBox(height: 18),

              // Teacher Quick Actions (Executive Action Bar)
              TeacherQuickActions(
                onOnlineClass: _openOnlineClassesHub,
                onCreateAssignment: _openCreateAssignment,
                onAiExamGenerator: _openAiExamGenerator,
                onAiLessonPlan: _openAiLessonPlanner,
                onBroadcast: _openAnnouncements,
              ),

              const SizedBox(height: 22),

              // Today's Classes & Schedule
              TodayClassesSection(
                classes: _classes,
                onTakeAttendance: _openAttendance,
                onViewRoster: _openRoster,
                onJoinLiveStage: (cls) => _openLiveClass(cls),
              ),

              const SizedBox(height: 18),

              // Student Support Radar
              AtRiskStudentsCard(
                students: _atRiskStudents,
                onAssignPractice: (st) {
                  _openCreateAssignment();
                },
                onSendNote: (st) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Follow-up note sent to ${st.name}.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Pending Submissions Grading Queue
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Reviews',
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
                      color: _pendingGrading.isEmpty
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _pendingGrading.isEmpty ? '0 Due' : '${_pendingGrading.length} Due',
                      style: TextStyle(
                        color: _pendingGrading.isEmpty ? AppColors.success : AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_pendingGrading.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 32),
                        SizedBox(height: 6),
                        Text(
                          'All caught up! No pending submissions.',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._pendingGrading.map((sub) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: Text(
                              sub['student'][0],
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub['student'],
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${sub['assignment']} • ${sub['class']}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              sub['autoScore'],
                              style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _gradeSubmission(sub),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Review',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
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
                    'My Batches & Cohorts',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
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

        const SizedBox(height: 16),

        ..._classes.map((cls) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cls.badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cls.standardBadge,
                          style: TextStyle(
                            color: cls.badgeColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cls.className,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cls.subject,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_alt_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${cls.studentCount} Students',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        cls.time,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openRoster(cls),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                          ),
                          icon: const Icon(Icons.badge_outlined, size: 15),
                          label: const Text(
                            'Student Roster',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.fact_check_rounded, size: 15),
                          label: const Text(
                            'Attendance',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
  // TAB 2: AI TEACHING SUITE (Clean, Professional, No Filler)
  // ============================================================
  Widget _buildAiSuiteTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        // Suite Header
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Teaching Suite',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Generative pedagogical tools tailored for high-impact instruction',
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

        const SizedBox(height: 18),

        // Tool 1: AI Lesson Planner
        _aiToolCard(
          icon: Icons.lightbulb_rounded,
          iconColor: const Color(0xFF818CF8),
          title: 'AI Lesson Planner',
          subtitle:
              'Generate structured 45-minute lesson plans with learning objectives, hooks, illustrations, student exercises, and exit checks.',
          badge: 'Curriculum Engine',
          actionText: 'Launch Lesson Planner',
          onTap: _openAiLessonPlanner,
        ),

        const SizedBox(height: 12),

        // Tool 2: AI Exam Maker
        _aiToolCard(
          icon: Icons.quiz_rounded,
          iconColor: AppColors.secondary,
          title: 'AI Exam & Paper Maker',
          subtitle:
              'Craft balanced test papers with Section A/B/C, marking schemes, and complete teacher answer keys tailored to your grade level.',
          badge: 'Assessment Specialist',
          actionText: 'Create Exam Paper',
          onTap: _openAiExamGenerator,
        ),

        const SizedBox(height: 12),

        // Tool 3: Virtual Classroom Stage & Live Notes
        _aiToolCard(
          icon: Icons.videocam_rounded,
          iconColor: const Color(0xFFEF4444),
          title: 'Virtual Classroom Stage & Live Notes',
          subtitle:
              'Host interactive classes with digital whiteboard, real-time student doubts queue, in-class pop quizzes, and automated Gemini AI transcription.',
          badge: 'Live Virtual Instruction',
          actionText: 'Open Classroom Hub',
          onTap: _openOnlineClassesHub,
        ),

        const SizedBox(height: 12),

        // Tool 4: Class Broadcast Manager
        _aiToolCard(
          icon: Icons.campaign_rounded,
          iconColor: AppColors.success,
          title: 'Batch Noticeboard & Broadcasts',
          subtitle:
              'Post homework updates, exam notices, and announcements directly to specific student cohorts with priority flags.',
          badge: 'Student Communication',
          actionText: 'Compose Announcement',
          onTap: _openAnnouncements,
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
      padding: const EdgeInsets.all(16),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      badge,
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor.withValues(alpha: 0.12),
                foregroundColor: iconColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: iconColor.withValues(alpha: 0.25)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 9),
              ),
              icon: Icon(icon, size: 15),
              label: Text(
                actionText,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
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
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
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
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_rounded, size: 15),
              label: const Text(
                'Assign',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ..._homeworkList.map((hw) {
          final submitted = hw['submitted'] as int;
          final total = hw['total'] as int;
          final pct = total > 0 ? (submitted / total) : 0.0;

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
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hw['class'],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${hw['subject']} • ${hw['points']} XP',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
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
                const SizedBox(height: 8),
                Text(
                  hw['title'],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
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
                        fontSize: 11.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$submitted/$total (${(pct * 100).toInt()}%)',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct >= 0.8
                          ? AppColors.success
                          : (pct >= 0.5 ? AppColors.secondary : AppColors.primary),
                    ),
                    minHeight: 5,
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
