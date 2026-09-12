import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class TeacherAnnouncement {
  final String title;
  final String target;
  final String message;
  final String date;
  final String tag;
  final Color tagColor;

  const TeacherAnnouncement({
    required this.title,
    required this.target,
    required this.message,
    required this.date,
    required this.tag,
    required this.tagColor,
  });
}

class TeacherAnnouncementsSheet extends StatefulWidget {
  const TeacherAnnouncementsSheet({super.key});

  @override
  State<TeacherAnnouncementsSheet> createState() => _TeacherAnnouncementsSheetState();
}

class _TeacherAnnouncementsSheetState extends State<TeacherAnnouncementsSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedTarget = 'All Batches';
  String _selectedTag = 'Notice';

  final List<String> _targets = [
    'All Batches',
    'Class 10-A (Secondary)',
    '1st Standard (Primary)',
    'B.Tech CSE Year 2',
    'PhD Scholar Cohort',
  ];

  final List<String> _tags = ['Notice', 'Exam Alert', 'Homework', 'Holiday'];

  final List<TeacherAnnouncement> _recentAnnouncements = [
    const TeacherAnnouncement(
      title: 'Mid-Term Physics Exam Schedule Announced',
      target: 'Class 10-A',
      message: 'The mid-term exam will be held next Monday at 9:00 AM in Hall 2. Make sure to review optics and wave kinematics.',
      date: '2 hours ago',
      tag: 'Exam Alert',
      tagColor: AppColors.danger,
    ),
    const TeacherAnnouncement(
      title: 'Interactive Math Shapes Workshop Tomorrow',
      target: '1st Standard',
      message: 'Dear parents and students, please bring color pencils tomorrow for our 2D/3D shapes interactive building activity!',
      date: 'Yesterday',
      tag: 'Notice',
      tagColor: AppColors.primary,
    ),
    const TeacherAnnouncement(
      title: 'Graph Algorithms Assignment Published',
      target: 'B.Tech CSE Year 2',
      message: 'Dijkstra and A* pathfinding implementation problem set is now live on EduSpark. Due this Friday 11:59 PM.',
      date: '2 days ago',
      tag: 'Homework',
      tagColor: AppColors.secondary,
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _postAnnouncement() {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both title and message.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Color color;
    switch (_selectedTag) {
      case 'Exam Alert':
        color = AppColors.danger;
        break;
      case 'Homework':
        color = AppColors.secondary;
        break;
      case 'Holiday':
        color = AppColors.success;
        break;
      default:
        color = AppColors.primary;
    }

    setState(() {
      _recentAnnouncements.insert(
        0,
        TeacherAnnouncement(
          title: title,
          target: _selectedTarget,
          message: message,
          date: 'Just now',
          tag: _selectedTag,
          tagColor: color,
        ),
      );
      _titleController.clear();
      _messageController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Announcement broadcasted to $_selectedTarget!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Class Announcements & Noticeboard',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Broadcast notices to students across your classes',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
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

            const Divider(color: AppColors.border, height: 20),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  // Post form
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
                        const Text(
                          'Create New Announcement',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedTarget,
                                    dropdownColor: AppColors.surface,
                                    isExpanded: true,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    items: _targets
                                        .map((t) => DropdownMenuItem(value: t, child: Text(t, maxLines: 1)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedTarget = val);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedTag,
                                    dropdownColor: AppColors.surface,
                                    isExpanded: true,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    items: _tags
                                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedTag = val);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: 'Headline / Announcement Title',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _messageController,
                          maxLines: 3,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Write the complete announcement details...',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton.icon(
                            onPressed: _postAnnouncement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text(
                              'Broadcast Announcement',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Recent Broadcasts',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ..._recentAnnouncements.map((a) => Container(
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: a.tagColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    a.tag,
                                    style: TextStyle(
                                      color: a.tagColor,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  a.target,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  a.date,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              a.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              a.message,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
