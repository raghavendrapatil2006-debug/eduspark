import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class FlashcardItem {
  final String subject;
  final String question;
  final String answer;
  final String example;

  const FlashcardItem({
    required this.subject,
    required this.question,
    required this.answer,
    required this.example,
  });
}

class FlashcardsSheet extends StatefulWidget {
  const FlashcardsSheet({super.key});

  @override
  State<FlashcardsSheet> createState() => _FlashcardsSheetState();
}

class _FlashcardsSheetState extends State<FlashcardsSheet> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  String _selectedFilter = 'All';

  final List<FlashcardItem> _allCards = const [
    FlashcardItem(
      subject: 'Science',
      question: 'What is Mitochondria commonly known as?',
      answer: 'The Powerhouse of the Cell.',
      example: 'Generates cellular ATP via respiration to power biochemical reactions.',
    ),
    FlashcardItem(
      subject: 'Maths',
      question: 'What is the Quadratic Formula for ax² + bx + c = 0?',
      answer: 'x = (-b ± √(b² - 4ac)) / (2a)',
      example: 'Used to calculate roots when simple factorization is difficult.',
    ),
    FlashcardItem(
      subject: 'Science',
      question: 'What is Newton\'s Third Law of Motion?',
      answer: 'For every action, there is an equal and opposite reaction.',
      example: 'When a rocket fires hot gas downward, the rocket is pushed upward.',
    ),
    FlashcardItem(
      subject: 'English',
      question: 'What is an Oxymoron?',
      answer: 'A figure of speech where two opposite ideas are joined for effect.',
      example: '"Deafening silence", "Cruel kindness", "Clearly confused".',
    ),
    FlashcardItem(
      subject: 'Maths',
      question: 'What is the sum of interior angles of a triangle?',
      answer: '180 degrees.',
      example: 'In any triangle (equilateral, isosceles, scalene), ∠A + ∠B + ∠C = 180°.',
    ),
    FlashcardItem(
      subject: 'Social Science',
      question: 'What are the three pillars of a Democratic government?',
      answer: 'Legislature, Executive, and Judiciary.',
      example: 'Provides checks and balances to prevent abuse of power.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCards = _selectedFilter == 'All'
        ? _allCards
        : _allCards.where((c) => c.subject == _selectedFilter).toList();

    final currentCard = filteredCards.isNotEmpty
        ? filteredCards[_currentIndex % filteredCards.length]
        : _allCards[0];

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
                    'Revision Flashcards',
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

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['All', 'Maths', 'Science', 'English', 'Social Science'].map((sub) {
                    final selected = sub == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(sub),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _selectedFilter = sub;
                              _currentIndex = 0;
                              _isFlipped = false;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Card Indicator
            Text(
              'Card ${_currentIndex + 1} of ${filteredCards.length}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            // Interactive Flippable Flashcard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFlipped = !_isFlipped;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _isFlipped
                          ? const Color(0xFF1E1B4B)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isFlipped
                            ? const Color(0xFF818CF8)
                            : AppColors.border,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isFlipped
                              ? const Color(0xFF818CF8).withValues(alpha: 0.15)
                              : Colors.transparent,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentCard.subject,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isFlipped ? 'ANSWER / CONCEPT' : 'QUESTION / TERM',
                          style: TextStyle(
                            color: _isFlipped
                                ? const Color(0xFF818CF8)
                                : AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _isFlipped ? currentCard.answer : currentCard.question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                          ),
                        ),
                        if (_isFlipped) ...[
                          const SizedBox(height: 18),
                          Text(
                            currentCard.example,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isFlipped
                                  ? 'Tap anywhere to flip back'
                                  : 'Tap anywhere to reveal answer',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentIndex > 0
                          ? () {
                              setState(() {
                                _currentIndex--;
                                _isFlipped = false;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentIndex < filteredCards.length - 1
                          ? () {
                              setState(() {
                                _currentIndex++;
                                _isFlipped = false;
                              });
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Deck completed! Great job! 🎉'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(
                        _currentIndex < filteredCards.length - 1
                            ? 'Next Card'
                            : 'Finish Deck',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
