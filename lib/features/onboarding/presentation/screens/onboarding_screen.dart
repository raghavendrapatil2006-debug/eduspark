import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/onboarding_3d_visuals.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      icon: Icons.auto_awesome,
      title: 'Your AI Tutor',
      description:
          'Scan any textbook page and get a simple explanation in seconds.',
    ),
    OnboardingData(
      icon: Icons.record_voice_over,
      title: 'Learn Your Way',
      description:
          'Ask questions with your voice and learn in English or Kannada.',
    ),
    OnboardingData(
      icon: Icons.trending_up,
      title: 'Grow Every Day',
      description:
          'Practice with quizzes, discover videos and build better study habits.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/role-selection');
    }
  }

  void _skip() {
    context.go('/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'EduSpark',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    data: _pages[index],
                    pageIndex: index,
                  );
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final int pageIndex;

  const _OnboardingPage({
    required this.data,
    required this.pageIndex,
  });

  Widget _build3DVisual() {
    switch (pageIndex) {
      case 0:
        return const AiTutorScanner3DVisual();
      case 1:
        return const VoiceLearning3DVisual();
      case 2:
        return const GrowthStreak3DVisual();
      default:
        return const AiTutorScanner3DVisual();
    }
  }

  List<String> _getHighlights() {
    switch (pageIndex) {
      case 0:
        return const ['Instant OCR Scan', 'Step-by-Step AI', 'KG to PhD Ready'];
      case 1:
        return const ['Natural Voice AI', 'English & ಕನ್ನಡ', 'Zero Latency'];
      case 2:
        return const ['Gamified XP', 'Streaks & Badges 🔥', 'Adaptive Quizzes'];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlights = _getHighlights();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Interactive 3D Visual Centerpiece
          _build3DVisual(),

          const SizedBox(height: 12),

          // 3D Gesture Hint Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 5),
                Text(
                  'Drag card to tilt & rotate in 3D',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Slide Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 12),

          // Slide Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.55,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Feature Highlights Chips
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: highlights.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
