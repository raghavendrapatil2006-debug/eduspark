import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/gemini_service.dart';

class MockClassroomSimulatorSheet extends StatefulWidget {
  const MockClassroomSimulatorSheet({super.key});

  @override
  State<MockClassroomSimulatorSheet> createState() =>
      _MockClassroomSimulatorSheetState();
}

class _MockClassroomSimulatorSheetState
    extends State<MockClassroomSimulatorSheet> {
  final TextEditingController _topicController =
      TextEditingController(text: "Newton's Third Law of Motion");
  final TextEditingController _teacherResponseController =
      TextEditingController();

  String _selectedGrade = '10th Standard';
  bool _sessionStarted = false;
  bool _isLoading = false;
  bool _isEvaluating = false;

  String? _simulatedStudentScenario;
  String? _feedbackReport;

  final List<String> _standards = [
    '1st Standard (Primary)',
    '5th Standard (Upper Primary)',
    '10th Standard (High School)',
    '12th Standard (Higher Secondary)',
    'B.Tech CSE (University Degree)',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    _teacherResponseController.dispose();
    super.dispose();
  }

  Future<void> _startSimulation() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify a topic to practice.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _sessionStarted = true;
      _simulatedStudentScenario = null;
      _feedbackReport = null;
    });

    final prompt = '''
You are a Teacher Training Simulation Engine.

The educator wants to practice teaching the topic "$topic" to students in "$_selectedGrade".

Simulate a realistic classroom moment where 2 or 3 students with distinct learning profiles raise their hands and ask realistic questions or express confusion.

Format as follows:
CLASSROOM CONTEXT:
[1 sentence describing the classroom setting and current student energy]

STUDENT 1: [Name] ([Learning Style, e.g., Visual learner / curious / confused])
"[Realistic, authentic question appropriate for $_selectedGrade]"

STUDENT 2: [Name] ([Learning Style])
"[A related follow-up or common misconception question for this grade]"

CHALLENGE FOR TEACHER:
[Tell the teacher what specific misconception or balance they need to address in their response]
''';

    try {
      final response = await GeminiService.instance.askQuestion(
        question: prompt,
        standard: _selectedGrade,
        language: 'English',
      );

      if (!mounted) return;
      setState(() {
        _simulatedStudentScenario = response;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Simulation error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _evaluateTeacherResponse() async {
    final teacherText = _teacherResponseController.text.trim();
    if (teacherText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write how you would explain this to the students.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isEvaluating = true;
      _feedbackReport = null;
    });

    final evalPrompt = '''
You are a Senior Master Teacher Mentor evaluating an educator's response during a simulated classroom practice session.

Grade Level: $_selectedGrade
Topic: ${_topicController.text}
Student Questions Given:
$_simulatedStudentScenario

Teacher's Explanation / Response to Students:
"$teacherText"

Evaluate this response constructively using the following rubrics:
1. AGE APPROPRIATENESS & CLARITY (Score /10)
   - Did the vocabulary, pacing, and depth fit $_selectedGrade?
2. STUDENT ENGAGEMENT & ANALOGIES (Score /10)
   - Did the teacher use relatable examples or encourage curiosity?
3. CONCEPTUAL ACCURACY & MISCONCEPTION HANDLING (Score /10)
   - Did the teacher resolve the students' core confusion correctly?

OVERALL MENTOR SCORE: [e.g. 9.2/10]

HIGHLIGHTS:
- [What the teacher did exceptionally well]

COACHING RECOMMENDATIONS:
- [1 or 2 actionable tips to make this explanation even more impactful in a real classroom]
''';

    try {
      final feedback = await GeminiService.instance.askQuestion(
        question: evalPrompt,
        standard: _selectedGrade,
        language: 'English',
      );

      if (!mounted) return;
      setState(() {
        _feedbackReport = feedback;
        _isEvaluating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isEvaluating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evaluation error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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

            // Header
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
                      Icons.record_voice_over_rounded,
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
                          'AI Classroom Teaching Simulator',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Practice teaching with simulated AI students & mentor feedback',
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  // Configuration row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Target Grade / Batch',
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
                                  value: _selectedGrade,
                                  dropdownColor: AppColors.surface,
                                  isExpanded: true,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: _standards
                                      .map((g) => DropdownMenuItem(
                                            value: g,
                                            child: Text(g, maxLines: 1),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedGrade = val);
                                    }
                                  },
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
                              'Topic to Teach',
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
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
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
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _startSimulation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.play_arrow_rounded, size: 18),
                      label: Text(
                        _isLoading
                            ? 'Simulating Classroom...'
                            : (_sessionStarted ? 'Regenerate Scenario' : 'Start Mock Teaching Session'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Simulated Student Scenario Box
                  if (_simulatedStudentScenario != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.groups_rounded,
                                color: AppColors.secondary,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Virtual Classroom Scenario',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _simulatedStudentScenario!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Teacher's response input
                    const Text(
                      'Your Explanation / Response to the Students:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _teacherResponseController,
                      maxLines: 4,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'e.g. "Great question Maya! Think of it like when you jump off a skateboard..."',
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

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _isEvaluating ? null : _evaluateTeacherResponse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isEvaluating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.grading_rounded, size: 18),
                        label: Text(
                          _isEvaluating
                              ? 'Mentor is Reviewing Your Teaching...'
                              : 'Submit Response for AI Mentorship Score',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],

                  // Mentor Feedback Report
                  if (_feedbackReport != null) ...[
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.success,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'AI Teacher Mentor Assessment',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _feedbackReport!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
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
}
