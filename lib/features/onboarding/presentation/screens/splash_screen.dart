import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _orbitController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _introController, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _introController, curve: Curves.easeIn));

    _introController.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        if (AuthService.instance.isAuthenticated) {
          if (AuthService.instance.isTeacher) {
            context.go('/teacher-dashboard');
          } else {
            context.go('/student-home');
          }
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Ambient Cosmic Space & Stars Backdrop
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _orbitController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SplashCosmicPainter(progress: _orbitController.value),
                );
              },
            ),
          ),

          // 2. Center 3D Floating Brand Experience
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_introController, _orbitController]),
                builder: (context, child) {
                  final t = _orbitController.value;
                  final rotX = math.sin(t * 2 * math.pi) * 0.18;
                  final rotY = math.cos(t * 2 * math.pi) * 0.28;
                  final rotZ = math.sin(t * 2 * math.pi) * 0.05;

                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 3D Orbital Emblem Container
                          SizedBox(
                            width: 220,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Ambient Glow
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF6366F1).withValues(alpha: 0.28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6366F1).withValues(alpha: 0.40),
                                        blurRadius: 75,
                                        spreadRadius: 15,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF06B6D4).withValues(alpha: 0.25),
                                        blurRadius: 40,
                                        spreadRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),

                                // 3D Orbiting Rings Canvas
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _SplashOrbitalRingsPainter(
                                      progress: t,
                                      rotX: rotX,
                                      rotY: rotY,
                                    ),
                                  ),
                                ),

                                // 3D Tilt Brand Emblem Cube
                                Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.002)
                                    ..rotateX(rotX)
                                    ..rotateY(rotY)
                                    ..rotateZ(rotZ),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF818CF8),
                                          Color(0xFF6366F1),
                                          Color(0xFF4338CA),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(
                                        color: const Color(0xFFC7D2FE).withValues(alpha: 0.6),
                                        width: 2.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1).withValues(alpha: 0.55),
                                          blurRadius: 38,
                                          offset: Offset(-rotY * 30, rotX * 30 + 12),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 52,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                // Floating 3D Pill Badge: AI Powered
                                Positioned(
                                  top: 14 + math.sin(t * 2 * math.pi) * 8,
                                  right: 0,
                                  child: _buildSplashPill(
                                    text: 'AI-Powered',
                                    color: const Color(0xFF38BDF8),
                                  ),
                                ),

                                // Floating 3D Pill Badge: KG to PhD
                                Positioned(
                                  bottom: 12 + math.cos(t * 2 * math.pi) * 8,
                                  left: 6,
                                  child: _buildSplashPill(
                                    text: 'KG to PhD',
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Brand Name with Gradient Glow
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFFC7D2FE),
                                Color(0xFF38BDF8),
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'EduSpark',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Slogan
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Learn Smarter. Ask Anything. Grow Every Day.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),

                          const SizedBox(height: 38),

                          // Futuristic Loading Shimmer Line
                          Container(
                            width: 140,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.transparent,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF6366F1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashPill({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SplashCosmicPainter extends CustomPainter {
  final double progress;

  _SplashCosmicPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Deep Radial Nebula Glow
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4F46E5).withValues(alpha: 0.18),
          const Color(0xFF0F172A).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.75));
    canvas.drawCircle(center, size.width * 0.75, nebulaPaint);

    // Starfield Points
    final starPaint = Paint()..color = Colors.white;
    final random = math.Random(101);
    for (int i = 0; i < 35; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = (math.sin(progress * 2 * math.pi + i) + 1) / 2;
      final radius = 0.8 + random.nextDouble() * 1.6;

      starPaint.color = Colors.white.withValues(alpha: 0.15 + twinkle * 0.65);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashCosmicPainter oldDelegate) => true;
}

class _SplashOrbitalRingsPainter extends CustomPainter {
  final double progress;
  final double rotX;
  final double rotY;

  _SplashOrbitalRingsPainter({
    required this.progress,
    required this.rotX,
    required this.rotY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 3D Orbital Outer Ring
    final ringPaint = Paint()
      ..color = const Color(0xFF818CF8).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.save();
    canvas.translate(center.dx + rotY * 18, center.dy + rotX * 18);
    canvas.rotate(progress * 2 * math.pi);
    canvas.scale(1.0, 0.42);
    canvas.drawCircle(Offset.zero, 95, ringPaint);

    // Orbiting Spark Dot
    final dotPaint = Paint()..color = const Color(0xFF38BDF8);
    final dotAngle = progress * 2 * math.pi;
    canvas.drawCircle(
      Offset(math.cos(dotAngle) * 95, math.sin(dotAngle) * 95),
      4.5,
      dotPaint,
    );
    canvas.restore();

    // 3D Counter-rotating Inner Ring
    canvas.save();
    canvas.translate(center.dx - rotY * 12, center.dy - rotX * 12);
    canvas.rotate(-progress * 2 * math.pi * 0.8 + math.pi / 4);
    canvas.scale(0.85, 0.36);
    ringPaint.color = const Color(0xFF06B6D4).withValues(alpha: 0.20);
    canvas.drawCircle(Offset.zero, 80, ringPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SplashOrbitalRingsPainter oldDelegate) => true;
}
