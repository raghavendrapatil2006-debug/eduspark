import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class TutorResultScreen extends StatelessWidget {
  final String result;

  const TutorResultScreen({super.key, required this.result});

  Map<String, String> _parseResult() {
    final sections = <String, String>{};

    final patterns = {
      'SUBJECT': RegExp(
        r'(?:\*\*)?\s*SUBJECT\s*:\s*(.*?)(?=(?:\*\*)?\s*GRADE\s*:|$)',
        dotAll: true,
        caseSensitive: false,
      ),
      'GRADE': RegExp(
        r'(?:\*\*)?\s*GRADE\s*:\s*(.*?)(?=(?:\*\*)?\s*TOPIC\s*:|$)',
        dotAll: true,
        caseSensitive: false,
      ),
      'TOPIC': RegExp(
        r'(?:\*\*)?\s*TOPIC\s*:\s*(.*?)(?=(?:\*\*)?\s*EXPLANATION\s*:|$)',
        dotAll: true,
        caseSensitive: false,
      ),
      'EXPLANATION': RegExp(
        r'(?:\*\*)?\s*EXPLANATION\s*:\s*(.*?)(?=(?:\*\*)?\s*(?:KEY[_ ]TERMS|EXAMPLE)\s*:|$)',
        dotAll: true,
        caseSensitive: false,
      ),
      'KEY_TERMS': RegExp(
        r'(?:\*\*)?\s*KEY[_ ]TERMS\s*:\s*(.*?)(?=(?:\*\*)?\s*EXAMPLE\s*:|$)',
        dotAll: true,
        caseSensitive: false,
      ),
      'EXAMPLE': RegExp(
        r'(?:\*\*)?\s*EXAMPLE\s*:\s*(.*)$',
        dotAll: true,
        caseSensitive: false,
      ),
    };

    for (final entry in patterns.entries) {
      final match = entry.value.firstMatch(result);

      if (match != null) {
        var value = match.group(1)?.trim() ?? '';

        value = value.replaceAll('**', '').replaceAll('---', '').trim();

        sections[entry.key] = value;
      }
    }

    return sections;
  }

  List<String> _parseTerms(String text) {
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.startsWith('-') ? line.substring(1).trim() : line)
        .toList();
  }

  String _cleanText(String text) {
    return text.replaceAll('**', '').replaceAll('---', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final sections = _parseResult();

    final subject = sections['SUBJECT'] ?? '';
    final grade = sections['GRADE'] ?? '';
    final topic = sections['TOPIC'] ?? '';
    final explanation = sections['EXPLANATION'] ?? '';
    final keyTerms = sections['KEY_TERMS'] ?? '';
    final example = sections['EXAMPLE'] ?? '';

    final terms = _parseTerms(keyTerms);

    final hasStructuredData =
        subject.isNotEmpty ||
        grade.isNotEmpty ||
        topic.isNotEmpty ||
        explanation.isNotEmpty ||
        terms.isNotEmpty ||
        example.isNotEmpty;

    if (!hasStructuredData) {
      return _buildFallbackScreen(context);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI Tutor',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EduSpark AI Tutor',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'I explained your textbook page for you.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Subject',
                      value: subject.isEmpty ? 'Not identified' : subject,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.school_rounded,
                      title: 'Grade',
                      value: grade.isEmpty ? 'Not identified' : grade,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _SectionCard(
                icon: Icons.topic_rounded,
                title: 'Topic',
                child: Text(
                  topic.isEmpty ? 'Topic not identified.' : topic,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _SectionCard(
                icon: Icons.lightbulb_rounded,
                title: 'Explanation',
                child: Text(
                  explanation.isEmpty
                      ? 'No explanation was returned.'
                      : explanation,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.65,
                  ),
                ),
              ),

              if (terms.isNotEmpty) ...[
                const SizedBox(height: 14),
                _SectionCard(
                  icon: Icons.key_rounded,
                  title: 'Key Terms',
                  child: Column(
                    children: [
                      for (int i = 0; i < terms.length; i++) ...[
                        _TermRow(number: i + 1, text: terms[i]),
                        if (i != terms.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              _SectionCard(
                icon: Icons.public_rounded,
                title: 'Real-world Example',
                child: Text(
                  example.isEmpty ? 'No example was returned.' : example,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.65,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI Tutor',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _SectionCard(
                icon: Icons.auto_awesome_rounded,
                title: 'AI Explanation',
                child: Text(
                  result.isEmpty
                      ? 'No response was returned.'
                      : _cleanText(result),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.65,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TermRow extends StatelessWidget {
  final int number;
  final String text;

  const _TermRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
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
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
