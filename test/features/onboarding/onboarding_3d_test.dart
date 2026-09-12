import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eduspark/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:eduspark/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:eduspark/features/onboarding/presentation/widgets/onboarding_3d_visuals.dart';

import 'package:go_router/go_router.dart';

void main() {
  group('3D First 3 Pages & Splash Screen Tests', () {
    testWidgets('SplashScreen renders 3D cosmic brand emblem and badges', (tester) async {
      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
          GoRoute(path: '/onboarding', builder: (_, _) => const Scaffold()),
          GoRoute(path: '/student-home', builder: (_, _) => const Scaffold()),
          GoRoute(path: '/teacher-dashboard', builder: (_, _) => const Scaffold()),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('EduSpark'), findsOneWidget);
      expect(find.text('AI-Powered'), findsOneWidget);
      expect(find.text('KG to PhD'), findsOneWidget);
      expect(find.text('Learn Smarter. Ask Anything. Grow Every Day.'), findsOneWidget);

      // Advance clock past the 2800ms timer
      await tester.pump(const Duration(milliseconds: 3000));
    });

    testWidgets('Onboarding Page 1 renders 3D AI Tutor scanner visual', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(AiTutorScanner3DVisual), findsOneWidget);
      expect(find.text('Your AI Tutor'), findsOneWidget);
      expect(find.text('AI Scan 99.8%'), findsOneWidget);
      expect(find.text('Smart OCR'), findsOneWidget);
      expect(find.text('Drag card to tilt & rotate in 3D'), findsOneWidget);
    });

    testWidgets('Onboarding Page 2 renders 3D Voice learning visual', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      // Swipe left to go to Page 2
      await tester.drag(find.byType(PageView), const Offset(-600, 0));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(VoiceLearning3DVisual), findsOneWidget);
      expect(find.text('Learn Your Way'), findsOneWidget);
      expect(find.text('ಕನ್ನಡದಲ್ಲಿ ಕಲಿಯಿರಿ 🇮🇳'), findsOneWidget);
      expect(find.text('Explain in English 🇬🇧'), findsOneWidget);
    });

    testWidgets('Onboarding Page 3 renders 3D Trophy and growth streak visual', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      // Swipe to Page 2
      await tester.drag(find.byType(PageView), const Offset(-900, 0));
      await tester.pump(const Duration(milliseconds: 600));

      // Swipe to Page 3
      await tester.drag(find.byType(PageView), const Offset(-900, 0));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(GrowthStreak3DVisual), findsOneWidget);
      expect(find.text('Grow Every Day'), findsOneWidget);
      expect(find.text('7 Day Streak 🔥'), findsOneWidget);
      expect(find.text('+50 XP Earned ⭐'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });
  });
}
