import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ContinueLearningCard extends StatelessWidget {
  final String topic;
  final String subject;
  final double progress;
  final IconData icon;
  final VoidCallback? onTap;

  const ContinueLearningCard({
    super.key,
    this.topic = 'Photosynthesis',
    this.subject = 'Science • Class 8',
    this.progress = 0.72,
    this.icon = Icons.science_rounded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.success,
                    size: 24,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          subject,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.play_circle_fill_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),

                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.success,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
