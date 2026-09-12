import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;
  final int xp;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    this.streakDays = 7,
    this.xp = 120,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.surface, AppColors.surfaceLight],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.05),
              blurRadius: 25,
            ),
          ],
        ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 26)),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays Day Streak',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Keep your streak alive!',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+$xp XP',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
