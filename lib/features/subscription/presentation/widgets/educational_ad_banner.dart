import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/subscription_service.dart';

class EducationalAdBanner extends StatefulWidget {
  final EdgeInsetsGeometry margin;

  const EducationalAdBanner({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  });

  @override
  State<EducationalAdBanner> createState() => _EducationalAdBannerState();
}

class _EducationalAdBannerState extends State<EducationalAdBanner> {
  bool _isTemporarilyDismissed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SubscriptionService.instance,
      builder: (context, _) {
        // Zero ads for Student Verified & EduSpark Pro members
        if (!SubscriptionService.instance.isFreeTier || _isTemporarilyDismissed) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: widget.margin,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E1B4B).withValues(alpha: 0.9),
                const Color(0xFF312E81).withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF818CF8).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF818CF8).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top tag row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'SPONSORED',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Google Developer Student Clubs • AI Masterclass',
                      style: TextStyle(
                        color: Color(0xFFC7D2FE),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Enjoy 100% Ad-Free learning with the Student Plan for just ₹99/mo!',
                          ),
                          action: SnackBarAction(
                            label: 'View ₹99 Plan',
                            textColor: AppColors.secondary,
                            onPressed: () => context.push('/subscription'),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      setState(() => _isTemporarilyDismissed = true);
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Ad Content Row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.code_rounded,
                      color: Color(0xFFA5B4FC),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join National AI & Robotics Hackathon 2026',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Free mentorship & certificate for school & college students',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Bottom action row: Register vs Remove Ads
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => context.push('/subscription'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.secondary,
                      size: 14,
                    ),
                    label: const Text(
                      'Remove Ads with Student Plan (₹99)',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Register Free',
                      style: TextStyle(
                        color: Color(0xFF1E1B4B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
