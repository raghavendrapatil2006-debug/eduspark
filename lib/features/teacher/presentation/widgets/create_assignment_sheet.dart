import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/teacher_curriculum_service.dart';

class AssignmentDraft {
  final String title;
  final String targetClass;
  final String subject;
  final String dueDate;
  final int maxPoints;
  final String instructions;

  const AssignmentDraft({
    required this.title,
    required this.targetClass,
    required this.subject,
    required this.dueDate,
    required this.maxPoints,
    required this.instructions,
  });
}

class CreateAssignmentSheet extends StatefulWidget {
  final ValueChanged<AssignmentDraft>? onAssignmentCreated;

  const CreateAssignmentSheet({super.key, this.onAssignmentCreated});

  @override
  State<CreateAssignmentSheet> createState() => _CreateAssignmentSheetState();
}

class _CreateAssignmentSheetState extends State<CreateAssignmentSheet> {
  final TextEditingController _titleController = TextEditingController();
  late final TextEditingController _subjectController;
  final TextEditingController _instructionsController = TextEditingController();
  late String _selectedClass;
  String _selectedDueDate = 'Tomorrow, 5:00 PM';
  int _selectedPoints = 50;

  final List<String> _classes = [
    'Class 10-A (Secondary)',
    '1st Standard (Primary)',
    'B.Tech CSE - Year 2 (Undergrad)',
    'PhD Seminar Batch (Doctoral)',
    'All Assigned Classes',
  ];

  @override
  void initState() {
    super.initState();
    final cur = TeacherCurriculumService.instance;
    _selectedClass = cur.activeBranch;
    _subjectController = TextEditingController(text: cur.activeSubject);
    if (!_classes.contains(_selectedClass)) {
      _classes.insert(0, _selectedClass);
    }
  }

  final List<int> _pointOptions = [25, 50, 75, 100];

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an assignment title.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final draft = AssignmentDraft(
      title: title,
      targetClass: _selectedClass,
      subject: _subjectController.text.trim(),
      dueDate: _selectedDueDate,
      maxPoints: _selectedPoints,
      instructions: _instructionsController.text.trim(),
    );

    widget.onAssignmentCreated?.call(draft);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assignment "$title" published to $_selectedClass!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.post_add_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Assignment',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Assign practice tasks & projects to your students',
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
                  // Target Class
                  const Text(
                    'Assign To Class / Batch',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedClass,
                        dropdownColor: AppColors.surface,
                        isExpanded: true,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        items: _classes
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedClass = val);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Title
                  const Text(
                    'Assignment Title',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. Chapter 4 Practice Problems & Notes',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Subject & Max Points
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Subject',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _subjectController,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Subject',
                                hintStyle: const TextStyle(color: AppColors.textMuted),
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reward / Marks',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _selectedPoints,
                                  dropdownColor: AppColors.surface,
                                  isExpanded: true,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: _pointOptions
                                      .map((p) => DropdownMenuItem(
                                            value: p,
                                            child: Text('$p XP Points'),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedPoints = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Due Date
                  const Text(
                    'Due Date & Submission Deadline',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedDueDate,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (_selectedDueDate.contains('Tomorrow')) {
                                _selectedDueDate = 'In 3 Days (Friday 11:59 PM)';
                              } else if (_selectedDueDate.contains('3 Days')) {
                                _selectedDueDate = 'Next Week (Monday 9:00 AM)';
                              } else {
                                _selectedDueDate = 'Tomorrow, 5:00 PM';
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Instructions
                  const Text(
                    'Instructions & Problem Set Details',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _instructionsController,
                    maxLines: 4,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Provide problem statements, textbook page numbers, or guidelines...',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text(
                        'Publish Assignment to Class',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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
}
