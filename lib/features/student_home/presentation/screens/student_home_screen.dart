import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/streak_card.dart';
import '../widgets/ai_tutor_card.dart';
import '../widgets/section_title.dart';
import '../widgets/subject_card.dart';
import '../widgets/continue_learning_card.dart';
import '../widgets/streak_details_sheet.dart';
import '../widgets/student_profile_sheet.dart';
import '../widgets/student_settings_sheet.dart';
import '../widgets/student_notifications_sheet.dart';
import '../widgets/student_help_support_sheet.dart';
import '../widgets/formula_of_the_day_card.dart';
import '../widgets/assignments_section.dart';
import '../widgets/class_leaderboard_sheet.dart';
import '../widgets/flashcards_sheet.dart';
import '../../../quizzes/presentation/screens/quizzes_screen.dart';
import '../../../ai_tutor/presentation/screens/ai_tutor_screen.dart';
import '../../../learning/presentation/screens/subject_topics_screen.dart';
import '../../../learning/presentation/screens/topic_lesson_screen.dart';
import '../../../../core/services/student_curriculum_service.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../features/subscription/presentation/widgets/educational_ad_banner.dart';
import '../widgets/student_standard_picker_sheet.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;
  String _studentName = 'Raghavendra';
  int _unreadNotifications = 2;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Today's study checklist
  List<_StudyTask> _todayTasks = [];

  @override
  void initState() {
    super.initState();
    _studentName = UserProfileService.instance.studentName;
    UserProfileService.instance.addListener(_onProfileUpdated);
    StudentCurriculumService.instance.addListener(_onCurriculumUpdated);
    StudentCurriculumService.instance.init();
    _loadAdaptiveStudentData();
  }

  void _onProfileUpdated() {
    if (mounted) {
      setState(() {
        _studentName = UserProfileService.instance.studentName;
      });
    }
  }

  void _onCurriculumUpdated() {
    if (mounted) {
      setState(() {
        _loadAdaptiveStudentData();
      });
    }
  }

  void _loadAdaptiveStudentData() {
    final activeStd = StudentCurriculumService.instance.activeStandard;
    if (UserProfileService.instance.standard != activeStd) {
      UserProfileService.instance.updateProfile(standard: activeStd);
    }
    final tasks = StudentCurriculumService.instance.getAdaptiveDailyTasks();
    _todayTasks = tasks.map((t) => _StudyTask(t.title, t.isCompleted)).toList();
  }

  @override
  void dispose() {
    UserProfileService.instance.removeListener(_onProfileUpdated);
    StudentCurriculumService.instance.removeListener(_onCurriculumUpdated);
    _searchController.dispose();
    super.dispose();
  }

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openStreakDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StreakDetailsSheet(streakDays: 7, xpEarned: 120),
    );
  }

  void _openProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentProfileSheet(
        initialName: _studentName,
        onNameChanged: (newName) {
          if (newName.isNotEmpty) {
            setState(() => _studentName = newName);
          }
        },
      ),
    );
  }

  void _openNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentNotificationsSheet(
        onAllRead: () {
          setState(() => _unreadNotifications = 0);
        },
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StudentSettingsSheet(),
    );
  }

  void _openHelpSupport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StudentHelpSupportSheet(),
    );
  }

  void _openSubjectScreen(String subject, IconData icon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubjectTopicsScreen(subject: subject, icon: icon),
      ),
    );
  }

  void _openTopicLesson(String topic, String subject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TopicLessonScreen(topic: topic, subject: subject),
      ),
    );
  }

  void _openLeaderboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ClassLeaderboardSheet(),
    );
  }

  void _openFlashcards() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FlashcardsSheet(),
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
            _buildHome(),
            _buildLearn(),
            _buildQuizzes(),
            _buildProgress(),
            _buildMore(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // 1. HOME TAB
  // ============================================================

  Widget _buildHome() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              AnimatedBuilder(
                animation: StudentCurriculumService.instance,
                builder: (context, _) => HomeHeader(
                  studentName: _studentName,
                  standard: StudentCurriculumService.instance.activeStandard,
                  unreadNotifications: _unreadNotifications,
                  onProfileTap: _openProfile,
                  onNotificationTap: _openNotifications,
                ),
              ),

              const SizedBox(height: 16),

              // Active Enrolled Standard / Degree Switcher Banner
              _buildEnrolledLevelBanner(),

              const SizedBox(height: 20),

              StreakCard(
                streakDays: 7,
                xp: 120,
                onTap: _openStreakDetails,
              ),

              const SizedBox(height: 16),

              // Educational Sponsored Banner (Free Tier only, hidden on Student/Pro)
              const EducationalAdBanner(margin: EdgeInsets.zero),

              const SizedBox(height: 20),

              // Today's Study Routine & Checklist
              _buildTodayTasksChecklist(),

              const SizedBox(height: 26),

              // AI Tutor Card
              const SectionTitle(title: 'What do you want to learn?'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AiTutorScreen()),
                  );
                },
                child: const AiTutorCard(),
              ),

              const SizedBox(height: 26),

              // Quick Actions
              const SectionTitle(title: 'Quick Actions'),
              const SizedBox(height: 12),
              _buildQuickActionsGrid(),

              const SizedBox(height: 26),

              // Your Subjects (Adaptive to selected Standard / Degree)
              SectionTitle(
                title: 'Your Subjects',
                actionText: 'See all',
                onActionTap: () {
                  setState(() => _currentIndex = 1);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 165,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: StudentCurriculumService.instance
                      .getAdaptiveSubjects()
                      .map(
                        (sub) => SubjectCard(
                          icon: sub.icon,
                          title: sub.title,
                          subtitle: sub.topicCountText,
                          onTap: () => _openSubjectScreen(sub.title, sub.icon),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 26),

              // Formula of the Day (Interactive Micro-learning)
              const FormulaOfTheDayCard(),

              const SizedBox(height: 26),

              // Continue Learning (Adaptive to selected Standard / Degree)
              SectionTitle(
                title: 'Continue Learning',
                actionText: 'View all',
                onActionTap: () {
                  setState(() => _currentIndex = 1);
                },
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final cl = StudentCurriculumService.instance
                      .getAdaptiveContinueLearning();
                  return ContinueLearningCard(
                    topic: cl.topic,
                    subject: '${cl.subject} • ${cl.standardSubtitle}',
                    progress: cl.progress,
                    icon: cl.icon,
                    onTap: () => _openTopicLesson(cl.topic, cl.subject),
                  );
                },
              ),

              const SizedBox(height: 26),

              // Assignments & School Tasks
              const AssignmentsSection(),

              const SizedBox(height: 26),

              // Daily Study Tip
              _buildDailyStudyTip(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildEnrolledLevelBanner() {
    return AnimatedBuilder(
      animation: StudentCurriculumService.instance,
      builder: (context, _) {
        final curService = StudentCurriculumService.instance;
        final standard = curService.activeStandard;
        final category = curService.activeCategory;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'YOUR STANDARD / DEGREE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '• $category',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      standard,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const StudentStandardPickerSheet(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_vert_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Change',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayTasksChecklist() {
    final completedCount = _todayTasks.where((t) => t.isCompleted).length;
    final totalCount = _todayTasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Today\'s Study Routine',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$completedCount of $totalCount Done',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          ..._todayTasks.map((task) {
            return InkWell(
              onTap: () {
                setState(() {
                  task.isCompleted = !task.isCompleted;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      task.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: task.isCompleted
                          ? AppColors.success
                          : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          color: task.isCompleted
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          fontSize: 13,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Row(
      children: [
        Expanded(
          child: _quickActionTile(
            icon: Icons.psychology_rounded,
            color: AppColors.primary,
            title: 'Ask Doubt',
            subtitle: 'AI Tutor',
            onTap: () => context.push('/ai-tutor/type'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickActionTile(
            icon: Icons.style_rounded,
            color: const Color(0xFF818CF8),
            title: 'Flashcards',
            subtitle: 'Revision',
            onTap: _openFlashcards,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickActionTile(
            icon: Icons.note_alt_rounded,
            color: AppColors.secondary,
            title: 'Notes',
            subtitle: 'AI Summary',
            onTap: () => _showNotesDialog(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickActionTile(
            icon: Icons.camera_alt_rounded,
            color: AppColors.success,
            title: 'Scan Book',
            subtitle: 'Camera',
            onTap: () => context.push('/ai-tutor/camera'),
          ),
        ),
      ],
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
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

  Widget _buildDailyStudyTip() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Study Tip: Active Recall',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Testing yourself with quick quizzes is 2x more effective than re-reading notes!',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Create Revision Notes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Chemical Bonding, Fractions...',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final topic = controller.text.trim();
              if (topic.isNotEmpty) {
                Navigator.of(ctx).pop();
                context.push('/ai-tutor/notes', extra: topic);
              }
            },
            child: const Text('Generate Notes'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 2. LEARN TAB
  // ============================================================

  Widget _buildLearn() {
    final activeCatalog =
        StudentCurriculumService.instance.getAdaptiveCatalogTopics();
    final matchingTopics = _searchQuery.isEmpty
        ? <StudentCatalogTopic>[]
        : activeCatalog
            .where((t) =>
                t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.description.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text(
                'Learn',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a subject or search any topic to start an interactive lesson.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),

              const SizedBox(height: 16),

              // Active Enrolled Standard / Degree Switcher Banner
              _buildEnrolledLevelBanner(),

              const SizedBox(height: 20),

              // Search Bar with clear icon
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _searchQuery.isNotEmpty
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search subjects or topics (e.g. Fractions, Light)...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            color: AppColors.textSecondary,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // IF SEARCHING: Show matching topic results
              if (_searchQuery.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Results',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${matchingTopics.length} found',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (matchingTopics.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No topics matching "$_searchQuery"',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            context.push('/ai-tutor/notes', extra: _searchQuery);
                          },
                          icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                          label: Text('Generate notes for "$_searchQuery" with AI'),
                        ),
                      ],
                    ),
                  )
                else
                  ...matchingTopics.map((topic) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _searchTopicCard(topic),
                      )),
              ] else ...[
                // DEFAULT LEARN TAB CONTENT
                const Text(
                  'Subjects',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                ...StudentCurriculumService.instance.getAdaptiveSubjects().map(
                  (sub) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _subjectLearningCard(
                      icon: sub.icon,
                      title: sub.title,
                      subtitle: sub.topicCountText,
                      progress: 0.45,
                      onTap: () => _openSubjectScreen(sub.title, sub.icon),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Continue Learning Prompt Card
                Builder(
                  builder: (context) {
                    final cl = StudentCurriculumService.instance
                        .getAdaptiveContinueLearning();
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              cl.icon,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Resume Active Topic',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${cl.subject} • ${cl.topic} (${(cl.progress * 100).round()}% done)',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _openTopicLesson(cl.topic, cl.subject);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 42),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Resume',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _searchTopicCard(StudentCatalogTopic topic) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _openTopicLesson(topic.title, topic.subject),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          topic.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            topic.subject,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subjectLearningCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${(progress * 100).round()}% completed',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 3. QUIZZES TAB
  // ============================================================

  Widget _buildQuizzes() {
    return const QuizzesScreen();
  }

  // ============================================================
  // 4. PROGRESS TAB (FULL GAMIFICATION & ANALYTICS)
  // ============================================================

  Widget _buildProgress() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your daily study habits, mastery, and badges.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 26),

          // 4 Core Metric Cards
          Row(
            children: [
              Expanded(
                child: _progressCard(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.secondary,
                  value: '7',
                  label: 'Day Streak 🔥',
                  onTap: _openStreakDetails,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _progressCard(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.secondary,
                  value: '1,240',
                  label: 'XP Earned ⭐',
                  onTap: _openStreakDetails,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _progressCard(
                  icon: Icons.quiz_rounded,
                  iconColor: AppColors.primary,
                  value: '18',
                  label: 'Quizzes Taken',
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _progressCard(
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.success,
                  value: '84%',
                  label: 'Accuracy Rate',
                  onTap: () {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Class Leaderboard & Weekly League Banner
          _buildLeaderboardBanner(),

          const SizedBox(height: 26),

          // Weekly Study Activity Bar Chart
          _buildWeeklyActivityChart(),

          const SizedBox(height: 24),

          // Weekly Goal Card
          _buildWeeklyGoalCard(),

          const SizedBox(height: 26),

          // Subject Mastery Progress Breakdown
          const Text(
            'Subject Mastery',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _buildSubjectMasteryCard('Maths', Icons.calculate_rounded, 0.68, 12, 18, AppColors.primary),
          const SizedBox(height: 12),
          _buildSubjectMasteryCard('Science', Icons.science_rounded, 0.75, 15, 20, AppColors.success),
          const SizedBox(height: 12),
          _buildSubjectMasteryCard('English', Icons.menu_book_rounded, 0.80, 12, 15, AppColors.secondary),
          const SizedBox(height: 12),
          _buildSubjectMasteryCard('Social Science', Icons.public_rounded, 0.50, 7, 14, const Color(0xFF9333EA)),

          const SizedBox(height: 28),

          // Badges & Achievements
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Badges & Trophies',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '4 of 6 Unlocked',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildBadgesGrid(),

          const SizedBox(height: 28),

          // Lifetime Learning Stats
          _buildLifetimeStats(),
        ],
      ),
    );
  }

  Widget _progressCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(height: 14),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardBanner() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openLeaderboard,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF581C87).withValues(alpha: 0.8),
                AppColors.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFC084FC).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFC084FC).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Silver League',
                          style: TextStyle(
                            color: Color(0xFFC084FC),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '• Rank #2 of 32',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$_studentName (You): 1,240 XP • 210 XP to #1 Priya S.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFC084FC),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyActivityChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final minutes = [35, 50, 25, 45, 40, 65, 30];
    const maxMinutes = 70;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Study Activity',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '4 hrs 50 mins this week',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '+18% vs last week',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final m = minutes[index];
                final factor = m / maxMinutes;
                final isToday = index == 6;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${m}m',
                      style: TextStyle(
                        color: isToday ? AppColors.primary : AppColors.textMuted,
                        fontSize: 10.5,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 28,
                      height: 85 * factor,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isToday
                              ? [AppColors.primary, const Color(0xFF818CF8)]
                              : [
                                  AppColors.primary.withValues(alpha: 0.35),
                                  AppColors.primary.withValues(alpha: 0.65),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: TextStyle(
                        color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Goal',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '70% Complete',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.7,
              minHeight: 10,
              backgroundColor: AppColors.border,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '7 of 10 learning sessions completed • 3 remaining',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectMasteryCard(
    String subject,
    IconData icon,
    double progress,
    int completed,
    int total,
    Color color,
  ) {
    return InkWell(
      onTap: () => _openSubjectScreen(subject, icon),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$completed of $total topics mastered',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesGrid() {
    final badges = [
      const _BadgeData('🔥', '7-Day Streak', 'Study 7 days in a row', true),
      const _BadgeData('🎯', 'Quiz Champion', 'Score 100% on any quiz', true),
      const _BadgeData('🤖', 'AI Explorer', 'Ask 20+ questions to AI Tutor', true),
      const _BadgeData('📚', 'Bookworm', 'Complete 15 topic lessons', true),
      const _BadgeData('⚡', 'Speed Demon', 'Finish quiz in < 3 mins', false),
      const _BadgeData('🌟', 'Top Ranker', 'Reach 2,000 XP', false),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final b = badges[index];
        return InkWell(
          onTap: () {
            _showBadgeDialog(b);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: b.unlocked ? AppColors.surface : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: b.unlocked
                    ? AppColors.secondary.withValues(alpha: 0.3)
                    : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: b.unlocked ? 1.0 : 0.35,
                  child: Text(b.emoji, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 8),
                Text(
                  b.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: b.unlocked ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  b.unlocked ? 'Unlocked ✓' : 'Locked 🔒',
                  style: TextStyle(
                    color: b.unlocked ? AppColors.secondary : AppColors.textMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBadgeDialog(_BadgeData badge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 54)),
            const SizedBox(height: 14),
            Text(
              badge.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: badge.unlocked
                    ? AppColors.secondary.withValues(alpha: 0.15)
                    : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge.unlocked ? 'Unlocked ✓ (+50 XP Bonus)' : 'In Progress...',
                style: TextStyle(
                  color: badge.unlocked ? AppColors.secondary : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lifetime Learning Stats',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LifetimeStatItem('28.5 hrs', 'Total Study Time'),
              _LifetimeStatItem('42', 'Doubts Cleared'),
              _LifetimeStatItem('18', 'Quizzes Mastered'),
              _LifetimeStatItem('9', 'Notes Created'),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 5. MORE TAB (INTERACTIVE ACCOUNT & SYSTEM)
  // ============================================================

  Widget _buildMore() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      children: [
        const Text(
          'More',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your profile, preferences, and app options.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Profile Card Header
        _buildMoreProfileHeader(),

        const SizedBox(height: 24),

        // Section: Main Navigation
        _moreTile(
          icon: Icons.person_outline_rounded,
          title: 'Student Profile',
          subtitle: 'Academic details, grade, target exams',
          onTap: _openProfile,
        ),
        _moreTile(
          icon: Icons.settings_outlined,
          title: 'Settings & Preferences',
          subtitle: 'Language, study targets, dark mode',
          onTap: _openSettings,
        ),
        _moreTile(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications Center',
          subtitle: '$_unreadNotifications unread alerts',
          badgeText: _unreadNotifications > 0 ? '$_unreadNotifications' : null,
          onTap: _openNotifications,
        ),
        _moreTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'FAQs, tutorials, contact support',
          onTap: _openHelpSupport,
        ),

        const SizedBox(height: 20),

        // Section: Switch Role
        _moreTile(
          icon: Icons.cast_for_education_rounded,
          title: 'Switch to Teacher Dashboard',
          subtitle: 'Switch mode to manage classes & students',
          color: AppColors.secondary,
          onTap: () {
            _confirmRoleSwitch();
          },
        ),

        _moreTile(
          icon: Icons.logout_rounded,
          title: 'Change Role / Log Out',
          subtitle: 'Return to welcome role selection',
          color: AppColors.danger,
          onTap: () {
            _confirmLogout();
          },
        ),

        const SizedBox(height: 24),
        const Center(
          child: Text(
            'EduSpark v1.0.0 • AI-Powered Learning',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _studentName.isNotEmpty ? _studentName[0].toUpperCase() : 'A',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _studentName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${UserProfileService.instance.standard} • ${UserProfileService.instance.board}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '1,240 XP • Level 4 Explorer ⭐',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _openProfile,
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moreTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badgeText,
    Color? color,
  }) {
    final effectiveColor = color ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: effectiveColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badgeText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmRoleSwitch() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Switch to Teacher Dashboard?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'You will be switched to Teacher Mode with educator analytics and classroom management tools.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/teacher-dashboard');
            },
            child: const Text('Switch Mode'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Change Role or Log Out?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'You will return to the EduSpark role selection screen.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/role-selection');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigationTap,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz_rounded),
            label: 'Quiz',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_rounded),
            selectedIcon: Icon(Icons.more_horiz_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class _BadgeData {
  final String emoji;
  final String title;
  final String description;
  final bool unlocked;

  const _BadgeData(this.emoji, this.title, this.description, this.unlocked);
}

class _LifetimeStatItem extends StatelessWidget {
  final String value;
  final String label;

  const _LifetimeStatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

class _StudyTask {
  final String title;
  bool isCompleted;

  _StudyTask(this.title, this.isCompleted);
}
