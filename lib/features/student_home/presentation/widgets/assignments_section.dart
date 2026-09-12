import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/student_curriculum_service.dart';

typedef AssignmentItem = StudentAssignment;

class AssignmentsSection extends StatefulWidget {
  const AssignmentsSection({super.key});

  @override
  State<AssignmentsSection> createState() => _AssignmentsSectionState();
}

class _AssignmentsSectionState extends State<AssignmentsSection> {
  List<AssignmentItem> _assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
    StudentCurriculumService.instance.addListener(_onCurriculumChanged);
  }

  @override
  void dispose() {
    StudentCurriculumService.instance.removeListener(_onCurriculumChanged);
    super.dispose();
  }

  void _onCurriculumChanged() {
    if (mounted) {
      setState(() {
        _loadAssignments();
      });
    }
  }

  void _loadAssignments() {
    _assignments = StudentCurriculumService.instance.getAdaptiveAssignments();
  }

  void _openAssignmentDetails(AssignmentItem assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AssignmentDetailsSheet(
        assignment: assignment,
        onSubmit: () {
          setState(() {
            assignment.isSubmitted = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assignments & Homework',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_assignments.where((a) => !a.isSubmitted).length} Pending',
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
        ..._assignments.map((assignment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAssignmentCard(assignment),
          );
        }),
      ],
    );
  }

  Widget _buildAssignmentCard(AssignmentItem assignment) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _openAssignmentDetails(assignment),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: assignment.isSubmitted
                  ? AppColors.border
                  : assignment.badgeColor.withValues(alpha: 0.25),
            ),
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
                      color: assignment.isSubmitted
                          ? AppColors.success.withValues(alpha: 0.15)
                          : assignment.badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      assignment.isSubmitted ? 'Submitted ✓' : assignment.status,
                      style: TextStyle(
                        color: assignment.isSubmitted
                            ? AppColors.success
                            : assignment.badgeColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${assignment.subject} • ${assignment.teacher}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                assignment.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    assignment.dueDate,
                    style: TextStyle(
                      color: assignment.isSubmitted
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${assignment.problemsCount} questions',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentDetailsSheet extends StatefulWidget {
  final AssignmentItem assignment;
  final VoidCallback onSubmit;

  const _AssignmentDetailsSheet({
    required this.assignment,
    required this.onSubmit,
  });

  @override
  State<_AssignmentDetailsSheet> createState() =>
      _AssignmentDetailsSheetState();
}

class _AssignmentDetailsSheetState extends State<_AssignmentDetailsSheet> {
  final Map<int, bool> _completedTasks = {};

  @override
  Widget build(BuildContext context) {
    final a = widget.assignment;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
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
                  Expanded(
                    child: Text(
                      a.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
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
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Teacher: ${a.teacher} • ${a.subject}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          a.dueDate,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    a.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tasks / Questions Checklist',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...a.tasks.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final task = entry.value;
                    final isChecked = _completedTasks[idx] ?? a.isSubmitted;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: CheckboxListTile(
                        value: isChecked,
                        activeColor: AppColors.success,
                        title: Text(
                          task,
                          style: TextStyle(
                            color: isChecked
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            fontSize: 13,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        onChanged: a.isSubmitted
                            ? null
                            : (val) {
                                setState(() {
                                  _completedTasks[idx] = val ?? false;
                                });
                              },
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/ai-tutor/type');
                    },
                    icon: const Icon(Icons.psychology_rounded, size: 18),
                    label: const Text('Ask AI Tutor for Step-by-Step Hints'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(0, 46),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: a.isSubmitted
                          ? null
                          : () {
                              widget.onSubmit();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Assignment submitted to teacher! +40 XP',
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                      child: Text(
                        a.isSubmitted
                            ? 'Submitted to Teacher ✓'
                            : 'Submit Assignment (+40 XP)',
                        style: const TextStyle(fontWeight: FontWeight.w800),
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
