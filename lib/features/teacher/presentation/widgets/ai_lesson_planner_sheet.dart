import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/teacher_curriculum_service.dart';
import '../../../../core/services/user_profile_service.dart';

class AiLessonPlannerSheet extends StatefulWidget {
  final String? initialSubject;
  final String? initialStandard;

  const AiLessonPlannerSheet({
    super.key,
    this.initialSubject,
    this.initialStandard,
  });

  @override
  State<AiLessonPlannerSheet> createState() => _AiLessonPlannerSheetState();
}

class _AiLessonPlannerSheetState extends State<AiLessonPlannerSheet> {
  final TextEditingController _topicController = TextEditingController();
  late final TextEditingController _subjectController;
  late String _selectedStandard;
  String _selectedDuration = '45 Minutes';
  bool _isLoading = false;
  String? _generatedPlan;

  @override
  void initState() {
    super.initState();
    final curService = TeacherCurriculumService.instance;
    _selectedStandard = widget.initialStandard ?? curService.activeBranch;
    _subjectController = TextEditingController(
      text: widget.initialSubject ?? curService.activeSubject,
    );
  }

  final List<String> _durations = [
    '30 Minutes',
    '45 Minutes',
    '60 Minutes',
    '90 Minutes (Lab / Seminar)',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _generateLessonPlan() async {
    final topic = _topicController.text.trim();
    final subject = _subjectController.text.trim();

    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a topic to generate a lesson plan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _generatedPlan = null;
    });

    final prompt = '''
You are an expert pedagogical instructional designer and master teacher educator creating a structured classroom lesson plan.

Subject: $subject
Topic: $topic
Target Standard / Level: $_selectedStandard
Class Duration: $_selectedDuration

Generate a complete, ready-to-teach lesson plan tailored precisely for students at the "$_selectedStandard" level.
Follow this format strictly using Markdown:

# Lesson Plan: $topic
**Target Audience:** $_selectedStandard | **Duration:** $_selectedDuration | **Subject:** $subject

---

### 🎯 1. Learning Objectives
- *By the end of this lesson, students will be able to:*
  1. [Specific measurable outcome]
  2. [Specific conceptual understanding]
  3. [Practical skill or application]

### 🪝 2. The Hook & Real-World Connection (First 5-7 Minutes)
- [A captivating real-world story, puzzle, visual analogy, or demonstration question that sparks student curiosity and relates directly to their daily life at this age/level]

### 📖 3. Core Concept Instruction & Whiteboard Diagrams (15-20 Minutes)
- **Step 1: Foundational Idea** - [Clear explanation with pedagogical tips]
- **Step 2: Deep Dive & Formula/Mechanism** - [Detailed breakdown matching $_selectedStandard rigor]
- **Draw on Board:** [Clear prompt describing what the teacher should sketch on the whiteboard]

### 💡 4. Interactive Guided Practice & Student Activity (10-15 Minutes)
- [An engaging pair activity, group discussion, or rapid problem-solving drill for the classroom]

### ❓ 5. Check for Understanding (Rapid-Fire Exit Quiz)
1. **Question 1:** [Targeted question]
2. **Question 2:** [Targeted question]
3. **Question 3:** [Higher-order thinking question]

### 🏠 6. Homework & Extension Challenge
- [Actionable homework assignment with 1 extension challenge for advanced students]

### 🧑‍🏫 Teacher Pro-Tip
- [Key misconception to watch out for in this topic and how to correct it easily]
''';

    try {
      final response = await GeminiService.instance.askQuestion(
        question: prompt,
        standard: _selectedStandard,
        language: 'English',
      );

      if (!mounted) return;
      setState(() {
        _generatedPlan = response;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate plan: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _copyToClipboard() {
    if (_generatedPlan == null) return;
    Clipboard.setData(ClipboardData(text: _generatedPlan!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lesson plan copied to clipboard!'),
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

            // Sheet title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF818CF8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: Color(0xFF818CF8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Lesson Planner',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Powered by Gemini • Customized for any standard',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_generatedPlan != null)
                    IconButton(
                      tooltip: 'Copy lesson plan',
                      onPressed: _copyToClipboard,
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: AppColors.primary,
                        size: 20,
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
                  // Form inputs
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
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _subjectController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                              ),
                              decoration: InputDecoration(
                                hintText: 'e.g., Physics, Maths',
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
                              'Duration',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
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
                                child: DropdownButton<String>(
                                  value: _selectedDuration,
                                  dropdownColor: AppColors.surface,
                                  isExpanded: true,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                  items: _durations
                                      .map((d) => DropdownMenuItem(
                                            value: d,
                                            child: Text(d, maxLines: 1),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedDuration = val);
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

                  const SizedBox(height: 12),

                  const Text(
                    'Target Standard / Education Level',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _openStandardSelectorModal(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.school_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedStandard,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Lesson Topic',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _topicController,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Newton’s Laws, Binary Trees, Photosynthesis',
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateLessonPlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF818CF8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: Text(
                        _isLoading
                            ? 'Gemini is Designing Lesson Plan...'
                            : 'Generate AI Lesson Plan',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_generatedPlan != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Generated Plan',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy_rounded, size: 14),
                          label: const Text(
                            'Copy All',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: MarkdownBody(
                        data: _generatedPlan!,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13.5,
                            height: 1.5,
                          ),
                          h1: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          h2: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                          h3: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                          listBullet: const TextStyle(
                            color: AppColors.secondary,
                          ),
                          strong: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          code: const TextStyle(
                            color: AppColors.secondary,
                            backgroundColor: AppColors.background,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openStandardSelectorModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        final categories = UserProfileService.standardsByCategory;
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Select Target Standard',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: categories.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 6),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ...entry.value.map((std) {
                          final isSelected = std == _selectedStandard;
                          return Material(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                setState(() {
                                  _selectedStandard = std;
                                });
                                Navigator.of(modalCtx).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  std,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
