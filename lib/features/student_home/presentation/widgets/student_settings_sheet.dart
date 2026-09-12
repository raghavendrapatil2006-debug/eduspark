import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/student_curriculum_service.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../features/subscription/domain/models/subscription_model.dart';
import 'student_standard_picker_sheet.dart';

class StudentSettingsSheet extends StatefulWidget {
  const StudentSettingsSheet({super.key});

  @override
  State<StudentSettingsSheet> createState() => _StudentSettingsSheetState();
}

class _StudentSettingsSheetState extends State<StudentSettingsSheet> {
  String _selectedLanguage = 'English';
  double _dailyGoalMinutes = 30;
  bool _dailyReminder = true;
  bool _streakAlerts = true;
  bool _quizAlerts = true;
  bool _audioTutor = true;
  bool _darkMode = true;
  String _aiDepth = 'Exam-Oriented';

  final List<String> _languages = [
    'English',
    'Hindi',
    'Kannada',
    'Telugu',
    'Tamil',
    'Marathi',
    'Spanish',
  ];

  final List<String> _depthOptions = [
    'Simple / Beginner',
    'Standard',
    'Exam-Oriented',
  ];

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.danger),
            SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of EduSpark?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // close dialog
              Navigator.of(context).pop(); // close settings sheet
              await AuthService.instance.signOut();
              if (mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    final user = AuthService.instance.currentUser;
    final name = user?.name ?? UserProfileService.instance.studentName;
    final email = user?.email ?? 'raghavendra@eduspark.ai';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'R',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 9, color: AppColors.success),
                              SizedBox(width: 3),
                              Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/teacher-dashboard');
                  },
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text(
                    'Teacher Studio',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: BorderSide(
                      color: AppColors.secondary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _confirmSignOut,
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(
                      color: AppColors.danger.withValues(alpha: 0.4),
                    ),
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

  Widget _buildSubscriptionSection() {
    return AnimatedBuilder(
      animation: SubscriptionService.instance,
      builder: (context, _) {
        final sub = SubscriptionService.instance;
        final tier = sub.currentTier;
        final isFree = sub.isFreeTier;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tier.color.withValues(alpha: 0.14),
                tier.color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: tier.color.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: tier.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: tier.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              tier.displayName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tier.color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tier.badgeLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isFree
                              ? '5 daily AI doubts • Educational Ads'
                              : 'Zero ads • Unlimited AI • 3D models unlocked',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFree ? AppColors.secondary : AppColors.surface,
                    foregroundColor: isFree ? Colors.white : tier.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isFree ? Colors.transparent : tier.color.withValues(alpha: 0.4),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    isFree
                        ? 'Upgrade to Student Plan (₹99/mo)'
                        : 'Manage Subscription & Change Plan',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Settings & Preferences',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                children: [
                  // Section: Account & Profile
                  _buildAccountSection(),

                  // Section: Subscription & Membership Plan
                  _buildSubscriptionSection(),

                  // Section: Learning Preferences
                  _sectionHeader('Learning Preferences'),

                  // Enrolled Standard & Degree (Adaptive Curriculum)
                  AnimatedBuilder(
                    animation: StudentCurriculumService.instance,
                    builder: (context, _) {
                      final cur = StudentCurriculumService.instance;
                      final standard = cur.activeStandard;
                      final category = cur.activeCategory;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          title: const Text(
                            'Enrolled Standard & Degree',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '$standard\n• $category',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.primary,
                          ),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) =>
                                  const StudentStandardPickerSheet(),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  _buildDropdownTile(
                    icon: Icons.language_rounded,
                    title: 'Explanation Language',
                    subtitle: 'AI tutor responses will follow this language',
                    value: _selectedLanguage,
                    items: _languages,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLanguage = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildDropdownTile(
                    icon: Icons.psychology_rounded,
                    title: 'AI Explanation Style',
                    subtitle: 'Depth of tutor answers and step details',
                    value: _aiDepth,
                    items: _depthOptions,
                    onChanged: (val) {
                      if (val != null) setState(() => _aiDepth = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Daily Goal Slider
                  Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Daily Study Target',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_dailyGoalMinutes.round()} mins/day',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.border,
                            thumbColor: AppColors.primary,
                          ),
                          child: Slider(
                            value: _dailyGoalMinutes,
                            min: 15,
                            max: 90,
                            divisions: 5,
                            onChanged: (val) {
                              setState(() => _dailyGoalMinutes = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section: Notifications
                  _sectionHeader('Notifications & Reminders'),
                  _buildSwitchTile(
                    icon: Icons.alarm_rounded,
                    title: 'Daily Study Reminder',
                    subtitle: 'Remind me to study at 6:00 PM',
                    value: _dailyReminder,
                    onChanged: (val) => setState(() => _dailyReminder = val),
                  ),
                  const SizedBox(height: 10),
                  _buildSwitchTile(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Streak Alert',
                    subtitle: 'Alert before midnight if streak is at risk',
                    value: _streakAlerts,
                    onChanged: (val) => setState(() => _streakAlerts = val),
                  ),
                  const SizedBox(height: 10),
                  _buildSwitchTile(
                    icon: Icons.quiz_rounded,
                    title: 'Daily Quiz Challenges',
                    subtitle: 'Get notified when new daily quizzes go live',
                    value: _quizAlerts,
                    onChanged: (val) => setState(() => _quizAlerts = val),
                  ),

                  const SizedBox(height: 24),

                  // Section: App & Display
                  _sectionHeader('App & System'),
                  _buildSwitchTile(
                    icon: Icons.volume_up_rounded,
                    title: 'Voice & Sound Effects',
                    subtitle: 'Audio cues on quiz answers & streak level-ups',
                    value: _audioTutor,
                    onChanged: (val) => setState(() => _audioTutor = val),
                  ),
                  const SizedBox(height: 10),
                  _buildSwitchTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Theme',
                    subtitle: 'EduSpark deep space night mode',
                    value: _darkMode,
                    onChanged: (val) => setState(() => _darkMode = val),
                  ),

                  const SizedBox(height: 24),

                  // Clear Cache Action
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.cleaning_services_rounded,
                        color: AppColors.secondary,
                      ),
                      title: const Text(
                        'Clear Offline Cached Content',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Free up storage from generated notes & images',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cached data cleared successfully.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Preferences saved.'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: const Text(
                        'Save Preferences',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        value: value,
        activeTrackColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.surface,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
