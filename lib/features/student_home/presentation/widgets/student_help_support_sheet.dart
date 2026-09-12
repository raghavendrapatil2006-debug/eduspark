import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class StudentHelpSupportSheet extends StatefulWidget {
  const StudentHelpSupportSheet({super.key});

  @override
  State<StudentHelpSupportSheet> createState() =>
      _StudentHelpSupportSheetState();
}

class _FaqItem {
  final String question;
  final String answer;
  bool isExpanded;

  _FaqItem({
    required this.question,
    required this.answer,
  }) : isExpanded = false;
}

class _StudentHelpSupportSheetState extends State<StudentHelpSupportSheet> {
  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'How do I ask questions to EduSpark AI Tutor?',
      answer:
          'Tap on the AI Tutor card or the "Ask a Question" option. You can type any question from your curriculum, speak using your microphone, or upload a textbook photo.',
    ),
    _FaqItem(
      question: 'Can I scan handwritten homework or textbook pages?',
      answer:
          'Yes! Use the "Scan Textbook" option in the AI Tutor. Snap a clear photo of the question or textbook page, and EduSpark will parse the text and explain the concepts step by step.',
    ),
    _FaqItem(
      question: 'How are XP points and Streaks calculated?',
      answer:
          'You earn XP by finishing topic lessons (+25 XP), completing AI quizzes (+50 XP for daily challenges), and asking doubts (+10 XP). Completing at least one activity daily keeps your streak burning.',
    ),
    _FaqItem(
      question: 'Can I study subjects in Hindi or other languages?',
      answer:
          'Yes, go to Settings & Preferences and change the Explanation Language to Hindi, Kannada, Telugu, Tamil, or Spanish. The AI Tutor will respond in your chosen language.',
    ),
    _FaqItem(
      question: 'How do I switch to Teacher Mode?',
      answer:
          'On the "More" tab, tap "Switch to Teacher Mode". This will navigate you directly to the Teacher Dashboard where you can manage classes and assignments.',
    ),
  ];

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
                    'Help & Support',
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
                  // Support banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need immediate help?',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Our team and AI assistants are available 24/7.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ..._faqs.map((faq) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: faq.isExpanded
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          iconColor: AppColors.primary,
                          collapsedIconColor: AppColors.textSecondary,
                          initiallyExpanded: faq.isExpanded,
                          title: Text(
                            faq.question,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onExpansionChanged: (expanded) {
                            setState(() => faq.isExpanded = expanded);
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                faq.answer,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Contact Us Card
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showContactDialog(context);
                      },
                      icon: const Icon(Icons.mail_outline_rounded, size: 18),
                      label: const Text(
                        'Send Feedback or Report an Issue',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
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

  void _showContactDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Contact Support',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Describe your question or issue...',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! Your feedback has been sent.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }
}
