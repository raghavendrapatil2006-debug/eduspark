import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eduspark/core/services/subscription_service.dart';
import 'package:eduspark/features/subscription/domain/models/subscription_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SubscriptionService Tests', () {
    test('Initializes with default Free with Ads tier', () async {
      final srv = SubscriptionService.instance;
      await srv.init();

      expect(srv.currentTier, equals(SubscriptionTier.free));
      expect(srv.isFreeTier, isTrue);
      expect(srv.hasActiveSubscription, isFalse);
      expect(srv.hasZeroAds, isFalse);
      expect(srv.canView3dModels, isFalse);
      expect(srv.isStudentVerified, isFalse);
      expect(srv.dailyAiQuestionsRemaining, equals(5));
    });

    test('Plans list contains Free (₹0), Student (₹99) and Pro (₹199)', () {
      final srv = SubscriptionService.instance;
      final plans = srv.plans;

      expect(plans.length, equals(3));

      final freePlan = plans.firstWhere((p) => p.tier == SubscriptionTier.free);
      expect(freePlan.monthlyPrice, equals(0));

      final studentPlan =
          plans.firstWhere((p) => p.tier == SubscriptionTier.studentVerified);
      expect(studentPlan.monthlyPrice, equals(99));
      expect(studentPlan.isPopular, isTrue);

      final proPlan =
          plans.firstWhere((p) => p.tier == SubscriptionTier.premium);
      expect(proPlan.monthlyPrice, equals(199));
    });

    test('Student verification submits and unlocks student discount eligibility', () async {
      final srv = SubscriptionService.instance;
      final success = await srv.submitStudentVerification(
        institutionName: 'IIT Bombay',
        studentName: 'Alex Johnson',
        rollNumber: '2024-CS-042',
      );

      expect(success, isTrue);
      expect(srv.isStudentVerified, isTrue);
      expect(srv.verificationData?.institutionName, equals('IIT Bombay'));
      expect(srv.verificationData?.rollNumber, equals('2024-CS-042'));
    });

    test('Upgrading to Student Verified Plan activates zero ads & 3D models', () async {
      final srv = SubscriptionService.instance;
      final upgraded = await srv.upgradePlan(
        tier: SubscriptionTier.studentVerified,
        cycle: 'monthly',
        paymentMethod: 'UPI',
      );

      expect(upgraded, isTrue);
      expect(srv.currentTier, equals(SubscriptionTier.studentVerified));
      expect(srv.hasActiveSubscription, isTrue);
      expect(srv.hasZeroAds, isTrue);
      expect(srv.canView3dModels, isTrue);
      expect(srv.expiryDate, isNotNull);
      expect(srv.expiryDate!.isAfter(DateTime.now()), isTrue);
    });

    test('Upgrading to EduSpark Pro unlocks premium teaching and academic suite', () async {
      final srv = SubscriptionService.instance;
      final upgraded = await srv.upgradePlan(
        tier: SubscriptionTier.premium,
        cycle: 'annual',
        paymentMethod: 'Card',
      );

      expect(upgraded, isTrue);
      expect(srv.currentTier, equals(SubscriptionTier.premium));
      expect(srv.isPremium, isTrue);
      expect(srv.hasZeroAds, isTrue);
      expect(srv.billingCycle, equals('annual'));
    });

    test('Canceling subscription reverts account back to Free tier', () async {
      final srv = SubscriptionService.instance;
      await srv.cancelSubscription();

      expect(srv.currentTier, equals(SubscriptionTier.free));
      expect(srv.isFreeTier, isTrue);
      expect(srv.hasActiveSubscription, isFalse);
      expect(srv.hasZeroAds, isFalse);
    });
  });
}
