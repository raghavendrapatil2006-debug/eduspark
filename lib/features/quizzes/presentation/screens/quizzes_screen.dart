import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/gemini_service.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  String selectedSubject = 'All';
  bool _isGenerating = false;

  final List<String> subjects = [
    'All',
    'Maths',
    'Science',
    'English',
    'Social',
  ];

  final List<_QuizItem> quizzes = const [
    _QuizItem(
      title: 'Maths Basics',
      subject: 'Maths',
      questions: 10,
      duration: '10 min',
      difficulty: 'Easy',
      icon: Icons.calculate_rounded,
    ),
    _QuizItem(
      title: 'Science Challenge',
      subject: 'Science',
      questions: 15,
      duration: '15 min',
      difficulty: 'Medium',
      icon: Icons.science_rounded,
    ),
    _QuizItem(
      title: 'English Grammar',
      subject: 'English',
      questions: 10,
      duration: '10 min',
      difficulty: 'Easy',
      icon: Icons.menu_book_rounded,
    ),
    _QuizItem(
      title: 'Social Studies',
      subject: 'Social',
      questions: 12,
      duration: '12 min',
      difficulty: 'Medium',
      icon: Icons.public_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredQuizzes = selectedSubject == 'All'
        ? quizzes
        : quizzes.where((quiz) => quiz.subject == selectedSubject).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quizzes',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Test your knowledge and earn XP',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDailyChallenge(),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose a subject',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${filteredQuizzes.length} quizzes',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _buildSubjectFilter(),

              const SizedBox(height: 18),

              ...filteredQuizzes.map(
                (quiz) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _QuizCard(quiz: quiz, onTap: () => _startQuiz(quiz)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.25),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Challenge',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'AI-generated quiz by EduSpark',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '+50 XP',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'Test yourself with 5 AI-generated questions.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isGenerating
                  ? null
                  : () {
                      _startDailyQuiz();
                    },
              child: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Start Daily Quiz',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilter() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final selected = subject == selectedSubject;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedSubject = subject;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                subject,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _startDailyQuiz() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final questions = await GeminiService.instance.generateQuiz(
        subject: 'General Knowledge',
        quizTitle: 'Daily Challenge',
        questionCount: 5,
      );

      if (!mounted) return;

      setState(() {
        _isGenerating = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AiQuizPlayScreen(
            title: 'Daily Challenge',
            subject: 'General Knowledge',
            questions: questions,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isGenerating = false;
      });

      _showError(e.toString());
    }
  }

  Future<void> _startQuiz(_QuizItem quiz) async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final questions = await GeminiService.instance.generateQuiz(
        subject: quiz.subject,
        quizTitle: quiz.title,
        questionCount: 5,
      );

      if (!mounted) return;

      setState(() {
        _isGenerating = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AiQuizPlayScreen(
            title: quiz.title,
            subject: quiz.subject,
            questions: questions,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isGenerating = false;
      });

      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class AiQuizPlayScreen extends StatefulWidget {
  final String title;
  final String subject;
  final List<GeminiQuizQuestion> questions;

  const AiQuizPlayScreen({
    super.key,
    required this.title,
    required this.subject,
    required this.questions,
  });

  @override
  State<AiQuizPlayScreen> createState() => _AiQuizPlayScreenState();
}

class _AiQuizPlayScreenState extends State<AiQuizPlayScreen> {
  int currentQuestion = 0;
  int score = 0;
  int? selectedAnswer;

  GeminiQuizQuestion get question => widget.questions[currentQuestion];

  void _selectAnswer(int index) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = index;

      if (index == question.answerIndex) {
        score++;
      }
    });
  }

  void _nextQuestion() {
    if (selectedAnswer == null) return;

    if (currentQuestion == widget.questions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizCompleteScreen(
            title: widget.title,
            score: score,
            total: widget.questions.length,
          ),
        ),
      );
      return;
    }

    setState(() {
      currentQuestion++;
      selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (currentQuestion + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${currentQuestion + 1} of ${widget.questions.length}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  question.question,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  itemCount: question.options.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _AnswerOption(
                      text: question.options[index],
                      index: index,
                      selected: selectedAnswer == index,
                      correct:
                          selectedAnswer != null &&
                          index == question.answerIndex,
                      wrong:
                          selectedAnswer == index &&
                          index != question.answerIndex,
                      onTap: () => _selectAnswer(index),
                    );
                  },
                ),
              ),

              if (selectedAnswer != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    question.explanation,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedAnswer == null ? null : _nextQuestion,
                  child: Text(
                    currentQuestion == widget.questions.length - 1
                        ? 'Finish Quiz'
                        : 'Next Question',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String text;
  final int index;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.text,
    required this.index,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color background = AppColors.surface;
    Color border = AppColors.border;

    if (correct) {
      background = Colors.green.withValues(alpha: 0.15);
      border = Colors.green;
    } else if (wrong) {
      background = Colors.red.withValues(alpha: 0.15);
      border = Colors.red;
    } else if (selected) {
      background = AppColors.primary.withValues(alpha: 0.12);
      border = AppColors.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Text(
                String.fromCharCode(65 + index),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (correct)
              const Icon(Icons.check_circle_rounded, color: Colors.green),
            if (wrong) const Icon(Icons.cancel_rounded, color: Colors.red),
          ],
        ),
      ),
    );
  }
}

class QuizCompleteScreen extends StatelessWidget {
  final String title;
  final int score;
  final int total;

  const QuizCompleteScreen({
    super.key,
    required this.title,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = ((score / total) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.primary,
                  size: 58,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Quiz Complete!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Excellent work! 🔥',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),

              const SizedBox(height: 34),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Score',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      '$score / $total',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to Quizzes',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final _QuizItem quiz;
  final VoidCallback onTap;

  const _QuizCard({required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
              child: Icon(quiz.icon, color: AppColors.primary, size: 26),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Text(
                        '${quiz.questions} questions',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        '•',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        quiz.duration,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quiz.difficulty,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizItem {
  final String title;
  final String subject;
  final int questions;
  final String duration;
  final String difficulty;
  final IconData icon;

  const _QuizItem({
    required this.title,
    required this.subject,
    required this.questions,
    required this.duration,
    required this.difficulty,
    required this.icon,
  });
}
