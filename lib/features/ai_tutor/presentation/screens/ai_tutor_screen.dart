import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

class AiTutorScreen extends StatelessWidget {
  const AiTutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 21,
            ),
            SizedBox(width: 8),
            Text('AI Tutor', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How do you want to learn?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Choose how you want to learn with EduSpark.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // =========================================================
              // TYPE QUESTION
              // =========================================================
              _TutorOptionCard(
                icon: Icons.edit_rounded,
                title: 'Type a Question',
                description:
                    'Type anything you want to learn and let EduSpark explain it step by step.',
                buttonText: 'Ask a Question',
                onTap: () {
                  context.push('/ai-tutor/type');
                },
              ),

              const SizedBox(height: 16),

              // =========================================================
              // STUDY NOTES
              // =========================================================
              _TutorOptionCard(
                icon: Icons.note_alt_rounded,
                title: 'Study Notes',
                description:
                    'Enter a topic and let EduSpark create clear, easy-to-revise study notes.',
                buttonText: 'Create Notes',
                onTap: () {
                  _showNotesTopicDialog(context);
                },
              ),

              const SizedBox(height: 16),

              // =========================================================
              // SCAN TEXTBOOK
              // =========================================================
              _TutorOptionCard(
                icon: Icons.camera_alt_rounded,
                title: 'Scan Textbook',
                description:
                    'Take a photo of a textbook page and let EduSpark explain it.',
                buttonText: 'Scan Page',
                onTap: () {
                  context.push('/ai-tutor/camera');
                },
              ),

              const SizedBox(height: 16),

              // =========================================================
              // VOICE
              // =========================================================
              _TutorOptionCard(
                icon: Icons.mic_rounded,
                title: 'Ask with Voice',
                description:
                    'Speak your question naturally and get an AI-powered answer.',
                buttonText: 'Start Speaking',
                onTap: () {
                  context.push('/ai-tutor/voice');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotesTopicDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(Icons.note_alt_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Create Study Notes',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter a topic',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              _openNotes(context, dialogContext, controller.text);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _openNotes(context, dialogContext, controller.text);
              },
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text(
                'Create Notes',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openNotes(
    BuildContext context,
    BuildContext dialogContext,
    String topic,
  ) {
    final cleanedTopic = topic.trim();

    if (cleanedTopic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a topic first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(dialogContext).pop();

    context.push('/ai-tutor/notes', extra: cleanedTopic);
  }
}

class _TutorOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  const _TutorOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 19),
              label: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
