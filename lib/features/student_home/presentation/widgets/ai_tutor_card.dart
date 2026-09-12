import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/tilt_3d_card.dart';

class AiTutorCard extends StatelessWidget {
  const AiTutorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Tilt3DCard(
      accentColor: AppColors.primary,
      maxTiltAngle: 0.12,
      padding: const EdgeInsets.all(22),
      onTap: () {
        context.push('/ai-tutor');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================================================
                  // AI TUTOR LABEL
                  // ============================================================
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'AI TUTOR',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ============================================================
                  // TITLE
                  // ============================================================
                  const Text(
                    'Ask EduSpark',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Ask anything and learn your way.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============================================================
                  // ACTION BUTTONS
                  // ============================================================
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // --------------------------------------------------------
                      // SCAN TEXTBOOK
                      // --------------------------------------------------------
                      GestureDetector(
                        onTap: () {
                          context.push('/ai-tutor/camera');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Scan Page',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --------------------------------------------------------
                      // ASK WITH VOICE
                      // --------------------------------------------------------
                      GestureDetector(
                        onTap: () {
                          context.push('/ai-tutor/voice');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.mic_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Voice',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --------------------------------------------------------
                      // TYPE QUESTION
                      // --------------------------------------------------------
                      GestureDetector(
                        onTap: () {
                          context.push('/ai-tutor/type');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.keyboard_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Type Question',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --------------------------------------------------------
                      // STUDY NOTES
                      // --------------------------------------------------------
                      GestureDetector(
                        onTap: () {
                          _showNotesTopicDialog(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.note_alt_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Study Notes',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ================================================================
            // AI ICON
            // ================================================================
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
    );
  }

  // ============================================================
  // STUDY NOTES DIALOG
  // ============================================================

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
              Expanded(
                child: Text(
                  'Create Study Notes',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
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
                final topic = controller.text.trim();

                if (topic.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a topic first.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();

                // Wait until the dialog has completely disappeared.
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (!context.mounted) return;

                  context.push('/ai-tutor/notes', extra: topic);
                });
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
}
