import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/role_selection_screen.dart';
import '../../features/student_home/presentation/screens/student_home_screen.dart';
import '../../features/teacher/presentation/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/presentation/screens/teacher_training_screen.dart';
import '../../features/ai_tutor/presentation/screens/tutor_result_screen.dart';
import '../../features/ai_tutor/presentation/screens/camera_scan_screen.dart';
import '../../features/ai_tutor/presentation/screens/ai_tutor_voice_screen.dart';
import '../../features/quizzes/presentation/screens/quizzes_screen.dart';
import '../../features/ai_tutor/presentation/screens/ai_tutor_type_question_screen.dart';
import '../../features/ai_tutor/presentation/screens/ai_tutor_notes_screen.dart';
import '../../features/learning/presentation/screens/subject_topics_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/phone_otp_screen.dart';

import '../../features/teacher/presentation/screens/live_classroom_stage_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../services/online_class_service.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) {
        return const SplashScreen();
      },
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) {
        final role = state.extra as String? ?? 'student';
        return LoginScreen(initialRole: role);
      },
    ),

    GoRoute(
      path: '/signup',
      builder: (context, state) {
        final role = state.extra as String? ?? 'student';
        return SignupScreen(initialRole: role);
      },
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) {
        return const ForgotPasswordScreen();
      },
    ),

    GoRoute(
      path: '/otp-login',
      builder: (context, state) {
        final role = state.extra as String? ?? 'student';
        return PhoneOtpScreen(initialRole: role);
      },
    ),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/ai-tutor/voice',
      builder: (context, state) => const AiTutorVoiceScreen(),
    ),

    GoRoute(
      path: '/role-selection',
      builder: (context, state) {
        return const RoleSelectionScreen();
      },
    ),

    GoRoute(
      path: '/student-home',
      builder: (context, state) {
        return const StudentHomeScreen();
      },
    ),

    GoRoute(
      path: '/teacher-dashboard',
      builder: (context, state) {
        return const TeacherDashboardScreen();
      },
    ),
    GoRoute(
      path: '/teacher-training',
      builder: (context, state) {
        return const TeacherTrainingScreen();
      },
    ),
    GoRoute(
      path: '/teacher/live-class',
      builder: (context, state) {
        final session = state.extra as OnlineClassSession? ??
            OnlineClassService.instance.currentLiveSession ??
            OnlineClassService.instance.sessions.first;
        return LiveClassroomStageScreen(session: session);
      },
    ),
    GoRoute(
      path: '/ai-tutor',
      builder: (context, state) {
        final result = state.extra as String? ?? '';

        return TutorResultScreen(result: result);
      },
    ),
    GoRoute(
      path: '/ai-tutor/camera',
      builder: (context, state) {
        return const CameraScanScreen();
      },
    ),
    GoRoute(
      path: '/quizzes',
      builder: (context, state) => const QuizzesScreen(),
    ),
    GoRoute(
      path: '/ai-tutor/type',
      builder: (context, state) {
        return const AiTutorTypeQuestionScreen();
      },
    ),
    GoRoute(
      path: '/ai-tutor/notes',
      builder: (context, state) {
        final topic = state.extra as String? ?? 'Study Topic';

        return AiTutorNotesScreen(topic: topic);
      },
    ),
    GoRoute(
      path: '/learn/subject',
      builder: (context, state) {
        final subject = state.extra as String? ?? 'Maths';

        IconData icon;

        switch (subject) {
          case 'Science':
            icon = Icons.science_rounded;
            break;
          case 'English':
            icon = Icons.menu_book_rounded;
            break;
          case 'Social Science':
            icon = Icons.public_rounded;
            break;
          default:
            icon = Icons.calculate_rounded;
        }

        return SubjectTopicsScreen(subject: subject, icon: icon);
      },
    ),
    GoRoute(
      path: '/subscription',
      builder: (context, state) {
        return const SubscriptionScreen();
      },
    ),
  ],
);
