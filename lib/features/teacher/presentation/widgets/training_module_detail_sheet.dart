import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class TrainingModule {
  final String id;
  final String title;
  final String category;
  final String duration;
  final int xpReward;
  final String description;
  final List<String> keyTakeaways;
  final List<TrainingQuizQuestion> questions;
  bool isCompleted;

  TrainingModule({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.xpReward,
    required this.description,
    required this.keyTakeaways,
    required this.questions,
    this.isCompleted = false,
  });
}

class TrainingQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const TrainingQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class TrainingModuleDetailSheet extends StatefulWidget {
  final TrainingModule module;
  final VoidCallback onCompleted;

  const TrainingModuleDetailSheet({
    super.key,
    required this.module,
    required this.onCompleted,
  });

  @override
  State<TrainingModuleDetailSheet> createState() =>
      _TrainingModuleDetailSheetState();
}

class _TrainingModuleDetailSheetState extends State<TrainingModuleDetailSheet> {
  int _currentTab = 0; // 0 = Content/Overview, 1 = Knowledge Check Quiz
  int _quizStep = 0;
  int? _selectedOption;
  bool _hasAnswered = false;
  int _score = 0;
  bool _quizFinished = false;

  void _selectOption(int index) {
    if (_hasAnswered) return;
    setState(() {
      _selectedOption = index;
      _hasAnswered = true;
      if (index == widget.module.questions[_quizStep].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_quizStep + 1 < widget.module.questions.length) {
      setState(() {
        _quizStep++;
        _selectedOption = null;
        _hasAnswered = false;
      });
    } else {
      setState(() {
        _quizFinished = true;
        if (_score >= 2) {
          widget.module.isCompleted = true;
          widget.onCompleted();
        }
      });
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.module.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.module.duration} • +${widget.module.xpReward} XP',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.module.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Segment tabs: Overview vs Quiz
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _currentTab = 0),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _currentTab == 0
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Training Lesson',
                              style: TextStyle(
                                color: _currentTab == 0
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _currentTab = 1),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _currentTab == 1
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Knowledge Check',
                                style: TextStyle(
                                  color: _currentTab == 1
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (widget.module.isCompleted) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: _currentTab == 0 ? _buildLessonBody() : _buildQuizBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonBody() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        // Video / Audio Classroom Simulation Player Card
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            gradient: LinearGradient(
              colors: [
                AppColors.surface,
                AppColors.primary.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary,
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Masterclass Video & Interactive Walkthrough',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.module.duration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Overview / Description
        const Text(
          'Module Overview',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.module.description,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 20),

        // Core Takeaways
        const Text(
          'Key Pedagogical Takeaways',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...widget.module.keyTakeaways.map(
          (takeaway) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    takeaway,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Action button to test knowledge
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _currentTab = 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.quiz_rounded, size: 18),
            label: const Text(
              'Start Knowledge Check Quiz',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizBody() {
    if (_quizFinished) {
      final passed = _score >= 2;
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: passed
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.danger.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                color: passed ? AppColors.success : AppColors.danger,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              passed ? 'Module Certified!' : 'Review & Try Again',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              passed
                  ? 'Congratulations! You answered $_score of ${widget.module.questions.length} questions correctly and earned +${widget.module.xpReward} Teacher XP.'
                  : 'You scored $_score of ${widget.module.questions.length}. You need at least 2 correct answers to certify this module.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (passed)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Complete & Return to Training Hub',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _quizStep = 0;
                      _score = 0;
                      _selectedOption = null;
                      _hasAnswered = false;
                      _quizFinished = false;
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retake Knowledge Check'),
                ),
              ),
          ],
        ),
      );
    }

    final q = widget.module.questions[_quizStep];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        // Progress header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_quizStep + 1} of ${widget.module.questions.length}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Score: $_score',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_quizStep + 1) / widget.module.questions.length,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 5,
          ),
        ),

        const SizedBox(height: 20),

        // Question text
        Text(
          q.question,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),

        const SizedBox(height: 18),

        // Options
        ...List.generate(q.options.length, (idx) {
          final isCorrect = idx == q.correctIndex;
          final isSelected = _selectedOption == idx;

          Color borderCol = AppColors.border;
          Color bgCol = AppColors.surface;

          if (_hasAnswered) {
            if (isCorrect) {
              borderCol = AppColors.success;
              bgCol = AppColors.success.withValues(alpha: 0.12);
            } else if (isSelected) {
              borderCol = AppColors.danger;
              bgCol = AppColors.danger.withValues(alpha: 0.12);
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: bgCol,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => _selectOption(idx),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _hasAnswered && isCorrect
                              ? AppColors.success
                              : (_hasAnswered && isSelected
                                  ? AppColors.danger
                                  : AppColors.surfaceLight),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + idx),
                            style: TextStyle(
                              color: _hasAnswered && (isCorrect || isSelected)
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q.options[idx],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        if (_hasAnswered) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Pedagogical Explanation',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  q.explanation,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _quizStep + 1 < widget.module.questions.length
                    ? 'Next Question'
                    : 'Finish Knowledge Check',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
