import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/subscription_service.dart';
import '../../../../features/subscription/domain/models/subscription_model.dart';

class HomeHeader extends StatelessWidget {
  final String studentName;
  final String? standard;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final int unreadNotifications;

  const HomeHeader({
    super.key,
    this.studentName = 'Guest',
    this.standard,
    this.onProfileTap,
    this.onNotificationTap,
    this.unreadNotifications = 0,
  });

  @override
  Widget build(BuildContext context) {
    final initial = studentName.isNotEmpty ? studentName[0].toUpperCase() : 'G';

    return Row(
      children: [
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, $studentName 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                standard != null && standard!.isNotEmpty
                    ? '$standard • Ready to learn?'
                    : 'Ready to learn something new?',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Subscription Tier Badge / Upgrade Button
        AnimatedBuilder(
          animation: SubscriptionService.instance,
          builder: (context, _) {
            final tier = SubscriptionService.instance.currentTier;
            final isFree = SubscriptionService.instance.isFreeTier;

            return GestureDetector(
              onTap: () => context.push('/subscription'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isFree
                      ? LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withValues(alpha: 0.2),
                            const Color(0xFF06B6D4).withValues(alpha: 0.15),
                          ],
                        )
                      : null,
                  color: isFree
                      ? null
                      : tier.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFree
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : tier.color.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFree ? Icons.auto_awesome_rounded : Icons.workspace_premium_rounded,
                      size: 13,
                      color: isFree ? AppColors.primary : tier.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isFree ? 'UPGRADE' : tier.shortName.toUpperCase(),
                      style: TextStyle(
                        color: isFree ? AppColors.primary : tier.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 8),

        GestureDetector(
          onTap: onNotificationTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
              if (unreadNotifications > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
