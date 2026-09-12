import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/subscription_service.dart';
import '../../domain/models/subscription_model.dart';
import '../widgets/payment_checkout_sheet.dart';
import '../widgets/student_id_verification_sheet.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _billingCycle = 'monthly';

  void _openVerificationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentIdVerificationSheet(
        onVerified: () {
          final studentPlan = SubscriptionService.instance.plans.firstWhere(
            (p) => p.tier == SubscriptionTier.studentVerified,
          );
          _openCheckout(studentPlan);
        },
      ),
    );
  }

  void _openCheckout(SubscriptionPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentCheckoutSheet(
        plan: plan,
        billingCycle: _billingCycle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'EduSpark Plans',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: SubscriptionService.instance,
        builder: (context, _) {
          final subService = SubscriptionService.instance;
          final plans = subService.plans;

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4F46E5).withValues(alpha: 0.25),
                      const Color(0xFF06B6D4).withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Accelerate Your Mastery',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Zero ads, unlimited Gemini AI doubts, interactive 3D anatomy/physics simulations & live classroom recordings.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 18),

                    // Active plan status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: subService.currentTier.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: subService.currentTier.color.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: subService.currentTier.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Current Tier: ${subService.currentTier.displayName}',
                            style: TextStyle(
                              color: subService.currentTier.color,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Billing Cycle Toggle (Monthly vs Annual)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _billingCycle = 'monthly'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _billingCycle == 'monthly'
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Monthly Billing',
                            style: TextStyle(
                              color: _billingCycle == 'monthly'
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _billingCycle = 'annual'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _billingCycle == 'annual'
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Annual Pass',
                                style: TextStyle(
                                  color: _billingCycle == 'annual'
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'SAVE 25%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Plans Cards List
              ...plans.map((plan) => _buildPlanCard(plan, subService)),

              const SizedBox(height: 28),

              // Feature Matrix Comparison Card
              _buildFeatureComparisonMatrix(),

              const SizedBox(height: 28),

              // FAQ Section
              _buildFaqSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, SubscriptionService subService) {
    final isCurrent = subService.currentTier == plan.tier;
    final price =
        _billingCycle == 'annual' ? plan.annualPrice : plan.monthlyPrice;
    final isStudentPlan = plan.tier == SubscriptionTier.studentVerified;
    final isPro = plan.tier == SubscriptionTier.premium;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPro
              ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
              : isStudentPlan
                  ? AppColors.secondary.withValues(alpha: 0.6)
                  : AppColors.border,
          width: (isPro || isStudentPlan) ? 1.6 : 1.0,
        ),
        boxShadow: [
          if (plan.isPopular || isPro)
            BoxShadow(
              color: plan.accentColor.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular / Recommended Banner
          if (plan.isPopular || isPro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: plan.accentColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Text(
                isStudentPlan
                    ? '🎓 RECOMMENDED FOR ALL STUDENTS • 50% DISCOUNT'
                    : '⚡ ULTIMATE ACADEMIC & TEACHER SUITE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ACTIVE PLAN',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  plan.tagline,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),

                // Pricing row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹$price',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _billingCycle == 'annual' ? '/year' : '/month',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: plan.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        plan.originalPriceNote,
                        style: TextStyle(
                          color: plan.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(color: AppColors.border, height: 26),

                // Features list
                ...plan.features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          f.isIncluded
                              ? Icons.check_circle_rounded
                              : Icons.cancel_outlined,
                          size: 16,
                          color: f.isIncluded ? AppColors.success : AppColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  f.title,
                                  style: TextStyle(
                                    color: f.isIncluded
                                        ? AppColors.textPrimary
                                        : AppColors.textMuted,
                                    fontSize: 12.5,
                                    fontWeight: f.isIncluded
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                    decoration: f.isIncluded
                                        ? null
                                        : TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                              if (f.highlight != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: plan.accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    f.highlight!,
                                    style: TextStyle(
                                      color: plan.accentColor,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Plan Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isCurrent
                        ? null
                        : () {
                            if (isStudentPlan && !subService.isStudentVerified) {
                              _openVerificationSheet();
                            } else if (plan.tier == SubscriptionTier.free) {
                              subService.cancelSubscription();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Switched back to Free plan.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              _openCheckout(plan);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrent ? AppColors.border : plan.accentColor,
                      foregroundColor: isCurrent ? AppColors.textMuted : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isCurrent
                          ? 'Current Active Plan'
                          : isStudentPlan
                              ? (subService.isStudentVerified
                                  ? 'Upgrade with Student Pass (₹$price)'
                                  : 'Verify Student ID & Unlock ₹$price')
                              : plan.tier == SubscriptionTier.free
                                  ? 'Use Free Plan'
                                  : 'Get EduSpark Pro (₹$price)',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparisonMatrix() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Features Matrix',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Side-by-side comparison of capabilities across all tiers',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
          const Divider(color: AppColors.border, height: 24),

          _buildMatrixRow('Zero Ads Experience', 'No', 'Yes (100%)', 'Yes (100%)'),
          _buildMatrixRow('AI Doubts & Tutor', '5 / Day', 'Unlimited', 'Unlimited'),
          _buildMatrixRow('3D Anatomical & STEM Models', 'Limited', 'Full Access', 'Full Access'),
          _buildMatrixRow('Virtual Live Broadcast Stage', 'No', 'Viewer Only', 'Full Host & REC'),
          _buildMatrixRow('AI Question Paper Generator', 'No', 'No', 'Unlimited + Key'),
          _buildMatrixRow('AI Lesson Planner', 'No', 'No', 'Full Access'),
          _buildMatrixRow('Multi-Device Access', '1 Device', '2 Devices', '5 Devices'),
        ],
      ),
    );
  }

  Widget _buildMatrixRow(String feature, String free, String student, String pro) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              feature,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              free,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              student,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              pro,
              style: const TextStyle(
                color: Color(0xFFF59E0B),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),

          _buildFaqItem(
            'Who qualifies for the ₹99 Student Plan?',
            'Any student enrolled in primary school, high school, pre-university, engineering, medical, or graduate degrees. Uploading a valid student ID card or entering your institution and roll number unlocks the ₹99 price immediately.',
          ),
          _buildFaqItem(
            'Can I switch or cancel my plan anytime?',
            'Yes! You have complete freedom to cancel, pause, or switch between Monthly and Annual passes anytime from your Profile Settings. No cancellation fees.',
          ),
          _buildFaqItem(
            'Which payment options can I use?',
            'We support all major Indian & international payment methods including UPI (Google Pay, PhonePe, Paytm), Debit/Credit Cards (Visa, MasterCard, RuPay), and Net Banking.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
