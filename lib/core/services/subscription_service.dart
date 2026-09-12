import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/subscription/domain/models/subscription_model.dart';
import '../constants/app_colors.dart';

class SubscriptionService extends ChangeNotifier {
  SubscriptionService._();

  static final SubscriptionService instance = SubscriptionService._();

  static const String _prefKeyTier = 'eduspark_sub_tier';
  static const String _prefKeyCycle = 'eduspark_sub_cycle';
  static const String _prefKeyExpiry = 'eduspark_sub_expiry';
  static const String _prefKeyVerification = 'eduspark_sub_verification';
  static const String _prefKeyAiQuestionsCount = 'eduspark_daily_ai_count';

  SubscriptionTier _currentTier = SubscriptionTier.free;
  String _billingCycle = 'monthly';
  DateTime? _expiryDate;
  StudentIdVerificationData? _verificationData;
  int _dailyAiQuestionsUsed = 0;
  bool _isInitialized = false;

  SubscriptionTier get currentTier => _currentTier;
  String get billingCycle => _billingCycle;
  DateTime? get expiryDate => _expiryDate;
  StudentIdVerificationData? get verificationData => _verificationData;
  bool get isInitialized => _isInitialized;

  bool get isFreeTier => _currentTier == SubscriptionTier.free;
  bool get hasActiveSubscription => _currentTier != SubscriptionTier.free;
  bool get hasZeroAds => _currentTier != SubscriptionTier.free;
  bool get canView3dModels => _currentTier != SubscriptionTier.free;
  bool get isStudentVerified =>
      _verificationData?.status == StudentVerificationStatus.verified;
  bool get isPremium => _currentTier == SubscriptionTier.premium;

  int get dailyAiLimit => isFreeTier ? 5 : 999999;
  int get dailyAiQuestionsRemaining =>
      isFreeTier ? (5 - _dailyAiQuestionsUsed).clamp(0, 5) : 999999;

  /// Comprehensive subscription plans definition
  List<SubscriptionPlan> get plans => [
        const SubscriptionPlan(
          id: 'free_tier',
          tier: SubscriptionTier.free,
          name: 'Free with Ads',
          tagline: 'Foundational learning for all students from KG to College',
          monthlyPrice: 0,
          annualPrice: 0,
          originalPriceNote: 'Always Free',
          accentColor: AppColors.textSecondary,
          features: [
            SubscriptionPlanFeature(title: 'Access to All Standards (KG to PhD)'),
            SubscriptionPlanFeature(title: 'Standard 2D Interactive Lessons'),
            SubscriptionPlanFeature(title: '5 AI Tutor Doubts per Day'),
            SubscriptionPlanFeature(title: 'Basic Practice Quizzes'),
            SubscriptionPlanFeature(
              title: 'Sponsored Educational Banners',
              isIncluded: false,
              highlight: 'Ad Supported',
            ),
            SubscriptionPlanFeature(
              title: 'Interactive 3D Anatomy & Physics Models',
              isIncluded: false,
            ),
            SubscriptionPlanFeature(
              title: 'Live Virtual Classroom Broadcast Stage',
              isIncluded: false,
            ),
          ],
        ),
        const SubscriptionPlan(
          id: 'student_verified',
          tier: SubscriptionTier.studentVerified,
          name: 'Student Verified',
          tagline: '50% Discount for School, College & University Students',
          monthlyPrice: 99,
          annualPrice: 999,
          originalPriceNote: 'Regular ₹199/mo (Save 50%)',
          isPopular: true,
          accentColor: AppColors.secondary,
          features: [
            SubscriptionPlanFeature(
              title: 'Zero Ads Experience',
              highlight: '100% Ad-Free',
            ),
            SubscriptionPlanFeature(
              title: 'Unlimited Gemini AI Doubt Solver & Voice Tutor',
              highlight: 'Unlimited',
            ),
            SubscriptionPlanFeature(
              title: 'Interactive 3D Human Anatomy, Physics & Chemistry Models',
            ),
            SubscriptionPlanFeature(title: 'Step-by-Step Numerical Formula Lab'),
            SubscriptionPlanFeature(title: 'Downloadable PDF Notes & Flashcards'),
            SubscriptionPlanFeature(title: 'Personalized Exam Target Practice'),
            SubscriptionPlanFeature(
              title: 'Live Classroom Recording Archive',
              isIncluded: false,
            ),
          ],
        ),
        const SubscriptionPlan(
          id: 'eduspark_pro',
          tier: SubscriptionTier.premium,
          name: 'EduSpark Pro',
          tagline: 'The Ultimate Academic Suite for Advanced Learners & Educators',
          monthlyPrice: 199,
          annualPrice: 1799,
          originalPriceNote: 'Save ₹589 on Annual Pass',
          accentColor: Color(0xFFF59E0B),
          features: [
            SubscriptionPlanFeature(
              title: 'Everything in Student Verified Plan',
            ),
            SubscriptionPlanFeature(
              title: 'Live Classroom Stage Broadcast & Cloud Recording',
              highlight: 'Educators & Students',
            ),
            SubscriptionPlanFeature(
              title: 'Gemini AI Co-Teacher Real-Time Scribe & Notes',
            ),
            SubscriptionPlanFeature(
              title: 'AI Question Paper Generator with Rubrics & Solutions',
            ),
            SubscriptionPlanFeature(
              title: 'AI Structured Pedagogical Lesson Planner',
            ),
            SubscriptionPlanFeature(
              title: 'Multi-Device Sync (Up to 5 Devices simultaneously)',
            ),
            SubscriptionPlanFeature(
              title: 'Priority 24/7 Academic & LMS Support',
            ),
          ],
        ),
      ];

  /// Initialize service and restore local subscription state
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final tierStr = prefs.getString(_prefKeyTier);
      final cycle = prefs.getString(_prefKeyCycle) ?? 'monthly';
      final expiryStr = prefs.getString(_prefKeyExpiry);
      final verStr = prefs.getString(_prefKeyVerification);
      _dailyAiQuestionsUsed = prefs.getInt(_prefKeyAiQuestionsCount) ?? 0;

      if (tierStr != null) {
        _currentTier = SubscriptionTier.values.firstWhere(
          (t) => t.name == tierStr,
          orElse: () => SubscriptionTier.free,
        );
      }

      _billingCycle = cycle;

      if (expiryStr != null) {
        final parsedExpiry = DateTime.tryParse(expiryStr);
        if (parsedExpiry != null) {
          if (parsedExpiry.isBefore(DateTime.now())) {
            // Subscription expired, revert to free
            _currentTier = SubscriptionTier.free;
            await prefs.setString(_prefKeyTier, SubscriptionTier.free.name);
          } else {
            _expiryDate = parsedExpiry;
          }
        }
      }

      if (verStr != null) {
        try {
          final Map<String, dynamic> data = jsonDecode(verStr);
          _verificationData = StudentIdVerificationData.fromJson(data);
        } catch (e) {
          debugPrint('Error parsing verification data: $e');
        }
      }
    } catch (e) {
      debugPrint('SubscriptionService init error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Submit and approve Student ID verification
  Future<bool> submitStudentVerification({
    required String institutionName,
    required String studentName,
    required String rollNumber,
    String? idCardImagePath,
  }) async {
    final verification = StudentIdVerificationData(
      institutionName: institutionName,
      studentName: studentName,
      rollNumber: rollNumber,
      idCardImagePath: idCardImagePath,
      submissionDate: DateTime.now(),
      status: StudentVerificationStatus.verified,
    );

    _verificationData = verification;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefKeyVerification,
        jsonEncode(verification.toJson()),
      );
    } catch (e) {
      debugPrint('Error storing verification: $e');
    }

    notifyListeners();
    return true;
  }

  /// Upgrade to Student Plan or EduSpark Pro
  Future<bool> upgradePlan({
    required SubscriptionTier tier,
    String cycle = 'monthly',
    String paymentMethod = 'UPI',
  }) async {
    _currentTier = tier;
    _billingCycle = cycle;

    // Compute expiry: 30 days for monthly, 365 for annual
    final days = cycle == 'annual' ? 365 : 30;
    _expiryDate = DateTime.now().add(Duration(days: days));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyTier, tier.name);
      await prefs.setString(_prefKeyCycle, cycle);
      await prefs.setString(_prefKeyExpiry, _expiryDate!.toIso8601String());
    } catch (e) {
      debugPrint('Error saving subscription: $e');
    }

    notifyListeners();
    return true;
  }

  /// Cancel active subscription
  Future<void> cancelSubscription() async {
    _currentTier = SubscriptionTier.free;
    _expiryDate = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyTier, SubscriptionTier.free.name);
      await prefs.remove(_prefKeyExpiry);
    } catch (e) {
      debugPrint('Error canceling subscription: $e');
    }

    notifyListeners();
  }

  /// Track AI questions for free tier limit
  void recordAiQuestionUsed() {
    if (isFreeTier) {
      _dailyAiQuestionsUsed++;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt(_prefKeyAiQuestionsCount, _dailyAiQuestionsUsed);
      });
      notifyListeners();
    }
  }
}
