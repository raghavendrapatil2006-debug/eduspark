import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/tilt_3d_card.dart';

import '../../../../core/services/auth_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _ambientController;
  late AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    // Ambient cosmic orb drift controller
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // 3D floating brand logo controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _selectStudent() {
    if (!AuthService.instance.isAuthenticated) {
      AuthService.instance.signInDemo(role: 'student');
    }
    context.go('/student-home');
  }

  void _selectTeacher() {
    if (!AuthService.instance.isAuthenticated) {
      AuthService.instance.signInDemo(role: 'teacher');
    }
    context.go('/teacher-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          // ============================================================
          // 1. AMBIENT COSMIC PARTICLES & GLOWING MESH BACKDROP
          // ============================================================
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _CosmicBackdropPainter(
                    progress: _ambientController.value,
                  ),
                );
              },
            ),
          ),

          // ============================================================
          // 2. MAIN SCROLLABLE CONTENT
          // ============================================================
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Bar with Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 13,
                              color: AppColors.secondary,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'EduSpark AI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push('/login');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.login_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // --------------------------------------------------------
                  // 3D FLOATING EDUSPARK EMBLEM
                  // --------------------------------------------------------
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, _) {
                      final val = _logoController.value;
                      final levitation = math.sin(val * 2 * math.pi) * 6;
                      final rotationY = math.sin(val * 2 * math.pi) * 0.18;

                      return Transform(
                        alignment: FractionalOffset.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0014)
                          ..translateByDouble(0.0, levitation, 0.0, 1.0)
                          ..rotateY(rotationY),
                        child: _buildFloatingBrandEmblem(),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // --------------------------------------------------------
                  // ECOSYSTEM BADGE
                  // --------------------------------------------------------
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary,
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'NEXT-GEN AI ACADEMIC SYSTEM',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // --------------------------------------------------------
                  // TITLE & SUBTITLE
                  // --------------------------------------------------------
                  const Text(
                    'Choose Your Space',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Experience adaptive intelligence crafted specifically for students and educators.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ============================================================
                  // 3. STUDENT 3D CARD
                  // ============================================================
                  Tilt3DCard(
                    accentColor: AppColors.primary,
                    onTap: _selectStudent,
                    floatingBadge: _buildFloatingBadge(
                      icon: Icons.school_rounded,
                      glowColor: AppColors.primary,
                      ringColor: const Color(0xFF64B5F6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Subtitle Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Text(
                                'LEARNER PORTAL • KG TO POSTDOC',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'I am a Student',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Personalized AI explanations tailored to your exact grade level, interactive quizzes, streak XP, and digital whiteboard.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Feature Pills
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _FeatureChip(
                              icon: Icons.auto_awesome,
                              label: 'Adaptive AI (KG - PhD)',
                              color: AppColors.primary,
                            ),
                            _FeatureChip(
                              icon: Icons.emoji_events_rounded,
                              label: 'Gamified Quizzes & XP',
                              color: AppColors.primary,
                            ),
                            _FeatureChip(
                              icon: Icons.camera_alt_rounded,
                              label: 'Instant Book Scanner',
                              color: AppColors.primary,
                            ),
                            _FeatureChip(
                              icon: Icons.mic_rounded,
                              label: 'Voice AI in Kannada & EN',
                              color: AppColors.primary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Interactive Action Button
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Enter Student Portal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ============================================================
                  // 4. TEACHER 3D CARD
                  // ============================================================
                  Tilt3DCard(
                    accentColor: AppColors.secondary,
                    onTap: _selectTeacher,
                    floatingBadge: _buildFloatingBadge(
                      icon: Icons.cast_for_education_rounded,
                      glowColor: AppColors.secondary,
                      ringColor: const Color(0xFFFFD54F),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Subtitle Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.secondary.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Text(
                                'FACULTY STUDIO • EDUCATOR SUITE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'I am an Educator',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Classroom management, 1-click AI lesson planner & test maker, student grading rubrics, and faculty induction training.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Feature Pills
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _FeatureChip(
                              icon: Icons.groups_rounded,
                              label: 'Classroom & Attendance',
                              color: AppColors.secondary,
                            ),
                            _FeatureChip(
                              icon: Icons.auto_stories_rounded,
                              label: 'AI Lesson & Exam Maker',
                              color: AppColors.secondary,
                            ),
                            _FeatureChip(
                              icon: Icons.workspace_premium_rounded,
                              label: 'Faculty Training & Cert',
                              color: AppColors.secondary,
                            ),
                            _FeatureChip(
                              icon: Icons.analytics_rounded,
                              label: 'Real-Time Class Metrics',
                              color: AppColors.secondary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Interactive Action Button
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Launch Educator Studio',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ============================================================
                  // 5. BOTTOM GLASSMORPHIC INFO DOCK
                  // ============================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'You can switch roles anytime in Settings.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'EduSpark AI • Enterprise-Grade Academic Platform',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BRAND EMBLEM WIDGET
  // ============================================================
  Widget _buildFloatingBrandEmblem() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF60A5FA),
            Color(0xFF2563EB),
            Color(0xFF1E3A8A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 28,
            spreadRadius: 4,
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 2.2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner glowing ring
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
          ),
          const Icon(
            Icons.auto_awesome_rounded,
            size: 38,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 3D FLOATING BADGE HELPER
  // ============================================================
  Widget _buildFloatingBadge({
    required IconData icon,
    required Color glowColor,
    required Color ringColor,
  }) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(
          color: ringColor.withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: ringColor,
          size: 26,
        ),
      ),
    );
  }
}

// ============================================================
// CHIP HELPER FOR CARD FEATURES
// ============================================================
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COSMIC AMBIENT BACKDROP PAINTER
// ============================================================
class _CosmicBackdropPainter extends CustomPainter {
  final double progress;

  _CosmicBackdropPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    // Moving Primary Blue Orb (top-right drift)
    final blueOrbCenter = Offset(
      size.width * 0.8 + math.sin(progress * 2 * math.pi) * 35,
      size.height * 0.22 + math.cos(progress * 2 * math.pi) * 25,
    );

    final bluePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.22),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: blueOrbCenter, radius: size.width * 0.55),
      );

    canvas.drawCircle(blueOrbCenter, size.width * 0.55, bluePaint);

    // Moving Amber Orb (bottom-left drift)
    final amberOrbCenter = Offset(
      size.width * 0.2 - math.cos(progress * 2 * math.pi) * 30,
      size.height * 0.75 - math.sin(progress * 2 * math.pi) * 30,
    );

    final amberPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.secondary.withValues(alpha: 0.16),
          AppColors.secondary.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: amberOrbCenter, radius: size.width * 0.5),
      );

    canvas.drawCircle(amberOrbCenter, size.width * 0.5, amberPaint);

    // Subtle star dust particles
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.25);
    final staticPoints = [
      Offset(size.width * 0.15, size.height * 0.12),
      Offset(size.width * 0.85, size.height * 0.10),
      Offset(size.width * 0.72, size.height * 0.40),
      Offset(size.width * 0.18, size.height * 0.55),
      Offset(size.width * 0.90, size.height * 0.68),
      Offset(size.width * 0.35, size.height * 0.85),
      Offset(size.width * 0.65, size.height * 0.92),
    ];

    for (final pt in staticPoints) {
      canvas.drawCircle(pt, 1.3, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicBackdropPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
