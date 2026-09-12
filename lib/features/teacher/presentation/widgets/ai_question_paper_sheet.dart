import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/teacher_curriculum_service.dart';
import '../../../../core/services/user_profile_service.dart';

class AiQuestionPaperSheet extends StatefulWidget {
  final String? initialSubject;
  final String? initialStandard;

  const AiQuestionPaperSheet({
    super.key,
    this.initialSubject,
    this.initialStandard,
  });

  @override
  State<AiQuestionPaperSheet> createState() => _AiQuestionPaperSheetState();
}

class _AiQuestionPaperSheetState extends State<AiQuestionPaperSheet> {
  final TextEditingController _topicController = TextEditingController();
  late final TextEditingController _subjectController;
  late String _selectedStandard;
  String _selectedDifficulty = 'Standard Board Level';
  String _selectedMarks = '25 Marks (Unit Test)';
  bool _isLoading = false;
  String? _generatedPaper;

  @override
  void initState() {
    super.initState();
    final curService = TeacherCurriculumService.instance;
    _selectedStandard = widget.initialStandard ?? curService.activeBranch;
    _subjectController = TextEditingController(
      text: widget.initialSubject ?? curService.activeSubject,
    );
  }

  final List<String> _difficulties = [
    'Easy / Foundational',
    'Standard Board Level',
    'Challenging / Competitive Level',
    'University / Rigorous Research Level',
  ];

  final List<String> _markSchemes = [
    '15 Marks (Quick Class Quiz)',
    '25 Marks (Unit Test)',
    '50 Marks (Mid-Term Assessment)',
    '100 Marks (Comprehensive Final Exam)',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _generateQuestionPaper() async {
    final topic = _topicController.text.trim();
    final subject = _subjectController.text.trim();

    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a topic for the question paper.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _generatedPaper = null;
    });

    final prompt = '''
You are a senior academic curriculum specialist and examiner creating an official, balanced examination paper.

Subject: $subject
Topic: $topic
Target Education Level: $_selectedStandard
Difficulty: $_selectedDifficulty
Mark Scheme: $_selectedMarks

Generate a complete question paper with marking scheme and answers strictly tailored for students at the "$_selectedStandard" level.
Format using clean Markdown:

# Examination Paper: $topic
**Subject:** $subject | **Standard:** $_selectedStandard | **Max Marks:** $_selectedMarks
**Instructions for Students:**
- All questions are compulsory.
- Show clear working/derivations where appropriate.

---

### SECTION A: Objective & Multiple Choice Questions
(Each question carries 1 Mark)
1. **Q1.** [Clear question]
   - A) [Option]
   - B) [Option]
   - C) [Option]
   - D) [Option]
2. **Q2.** [Clear question]
   - A) [Option]
   - B) [Option]
   - C) [Option]
   - D) [Option]
3. **Q3.** [Clear question]
   - A) [Option]
   - B) [Option]
   - C) [Option]
   - D) [Option]

### SECTION B: Short Answer & Conceptual Questions
(Each question carries 2 or 3 Marks)
4. **Q4.** [Conceptual question asking 'why' or 'explain with an example'] *(3 Marks)*
5. **Q5.** [Numerical or application problem] *(3 Marks)*

### SECTION C: Detailed Problem / Derivation / Case Study
(Each question carries 5 Marks)
6. **Q6.** [In-depth question requiring step-by-step mathematical derivation, mechanism, or analytical essay breakdown matching $_selectedStandard level] *(5 Marks)*

---

### 🔑 TEACHER ANSWER KEY & MARKING SCHEME
- **Section A Answers:**
  - Q1: [Correct option and 1-line reason]
  - Q2: [Correct option and 1-line reason]
  - Q3: [Correct option and 1-line reason]
- **Section B Key Points:**
  - Q4: [Core keywords needed for full marks]
  - Q5: [Final answer with unit and step breakdown]
- **Section C Marking Criteria:**
  - Q6: [Mark allocation: e.g. 2 marks for formula/diagram, 2 marks for derivation, 1 mark for conclusion]
''';

    try {
      final response = await GeminiService.instance.askQuestion(
        question: prompt,
        standard: _selectedStandard,
        language: 'English',
      );

      if (!mounted) return;
      setState(() {
        _generatedPaper = response;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate paper: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _copyToClipboard() {
    if (_generatedPaper == null) return;
    Clipboard.setData(ClipboardData(text: _generatedPaper!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question paper copied to clipboard!'),
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
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Exam & Paper Maker',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Generates balanced test papers & answer keys',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_generatedPaper != null)
                    IconButton(
                      tooltip: 'Copy test paper',
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
                                hintText: 'e.g., Chemistry, Math',
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
                              'Mark Scheme',
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
                                  value: _selectedMarks,
                                  dropdownColor: AppColors.surface,
                                  isExpanded: true,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12.5,
                                  ),
                                  items: _markSchemes
                                      .map((m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(m, maxLines: 1),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedMarks = val);
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

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Standard / Level',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _openStandardSelectorModal,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedStandard,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Difficulty',
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
                                  value: _selectedDifficulty,
                                  dropdownColor: AppColors.surface,
                                  isExpanded: true,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                  ),
                                  items: _difficulties
                                      .map((d) => DropdownMenuItem(
                                            value: d,
                                            child: Text(d, maxLines: 1),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedDifficulty = val);
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
                    'Topic & Concepts to Cover',
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
                      hintText: 'e.g. Thermodynamics, Coordinate Geometry, Cell Cycle',
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
                      onPressed: _isLoading ? null : _generateQuestionPaper,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.black,
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
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: Text(
                        _isLoading
                            ? 'Gemini is Crafting Question Paper...'
                            : 'Generate Exam Paper with AI',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_generatedPaper != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Test Paper Preview',
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
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: MarkdownBody(
                        data: _generatedPaper!,
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
