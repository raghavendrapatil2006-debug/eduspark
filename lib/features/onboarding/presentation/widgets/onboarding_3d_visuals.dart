import 'dart:math' as math;
import 'package:flutter/material.dart';

// ============================================================================
// 1. PAGE 1: 3D AI TUTOR SCANNER VISUAL
// Interactive 3D Holographic Textbook with moving laser scanner, orbital rings,
// floating depth badges, and real-time gesture tilting.
// ============================================================================

class AiTutorScanner3DVisual extends StatefulWidget {
  const AiTutorScanner3DVisual({super.key});

  @override
  State<AiTutorScanner3DVisual> createState() => _AiTutorScanner3DVisualState();
}

class _AiTutorScanner3DVisualState extends State<AiTutorScanner3DVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  // Interactive 3D tilt coordinates (-1.0 to 1.0)
  double _touchX = 0.0;
  double _touchY = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (size.width == 0 || size.height == 0) return;
    setState(() {
      _isDragging = true;
      _touchX = ((details.localPosition.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
      _touchY = ((details.localPosition.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);
    });
  }

  void _onPanEnd() {
    setState(() {
      _isDragging = false;
      _touchX = 0.0;
      _touchY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 240);

        return GestureDetector(
          onPanUpdate: (details) => _onPanUpdate(details, size),
          onPanEnd: (_) => _onPanEnd(),
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final t = _animController.value;
              final idleTiltX = math.sin(t * 2 * math.pi) * 0.08;
              final idleTiltY = math.cos(t * 2 * math.pi) * 0.12;

              final targetRotX = _isDragging ? -_touchY * 0.35 : idleTiltX;
              final targetRotY = _isDragging ? _touchX * 0.40 : idleTiltY;

              return SizedBox(
                width: double.infinity,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Ambient Glow
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6366F1).withValues(alpha: 0.18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.28),
                                blurRadius: 70,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Rotating 3D Particle & Ring Canvas
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _HoloScannerRingPainter(
                          progress: t,
                          accentColor: const Color(0xFF6366F1),
                        ),
                      ),
                    ),

                    // 3D Perspective Card / Textbook
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0018)
                        ..rotateX(targetRotX)
                        ..rotateY(targetRotY),
                      child: Container(
                        width: 160,
                        height: 190,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1E2538),
                              const Color(0xFF111726).withValues(alpha: 0.95),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                              blurRadius: 30,
                              offset: Offset(-targetRotY * 30, targetRotX * 30 + 12),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Content Blueprint Lines inside textbook
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.auto_awesome,
                                          color: Color(0xFF818CF8),
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        height: 8,
                                        width: 55,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    height: 6,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 6,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  // Formula preview
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: const Text(
                                      'E = mc² • ∫ f(x)dx',
                                      style: TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Dynamic 3D Scanning Laser Beam
                            Positioned(
                              top: 15 + ((math.sin(t * 2 * math.pi) + 1) / 2) * 150,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF38BDF8),
                                      Colors.white,
                                      Color(0xFF38BDF8),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Floating 3D Depth Badge 1: Instant AI Scan (Z: 40)
                    Positioned(
                      top: 18 + math.sin(t * 2 * math.pi + 1.0) * 8,
                      right: 28,
                      child: _buildFloatingGlassBadge(
                        icon: Icons.qr_code_scanner_rounded,
                        text: 'AI Scan 99.8%',
                        color: const Color(0xFF10B981),
                      ),
                    ),

                    // Floating 3D Depth Badge 2: Formula Decoded (Z: 50)
                    Positioned(
                      bottom: 22 + math.cos(t * 2 * math.pi + 2.0) * 8,
                      left: 24,
                      child: _buildFloatingGlassBadge(
                        icon: Icons.functions_rounded,
                        text: 'Smart OCR',
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingGlassBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoloScannerRingPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  _HoloScannerRingPainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 105.0;

    final ringPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Outer ring with slight tilt
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * 2 * math.pi);
    canvas.scale(1.0, 0.45); // 3D perspective flattening
    canvas.drawCircle(Offset.zero, radius, ringPaint);

    // Orbital Nodes
    final nodePaint = Paint()..color = const Color(0xFF38BDF8);
    final angle = progress * 2 * math.pi;
    final nodeX = math.cos(angle) * radius;
    final nodeY = math.sin(angle) * radius;
    canvas.drawCircle(Offset(nodeX, nodeY), 4.5, nodePaint);

    // Second counter-rotating inner ring
    canvas.restore();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-progress * 2 * math.pi * 0.7);
    canvas.scale(0.85, 0.38);
    ringPaint.color = const Color(0xFF06B6D4).withValues(alpha: 0.22);
    canvas.drawCircle(Offset.zero, radius * 0.8, ringPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HoloScannerRingPainter oldDelegate) => true;
}

// ============================================================================
// 2. PAGE 2: 3D VOICE & MULTI-LINGUAL SOUND SPHERE VISUAL
// 3D sonic soundwave orb rotating along multiple axes, dynamic equalizer waves,
// floating speech bubbles ("English", "ಕನ್ನಡ", "Hindi"), and touch tilt.
// ============================================================================

class VoiceLearning3DVisual extends StatefulWidget {
  const VoiceLearning3DVisual({super.key});

  @override
  State<VoiceLearning3DVisual> createState() => _VoiceLearning3DVisualState();
}

class _VoiceLearning3DVisualState extends State<VoiceLearning3DVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  double _touchX = 0.0;
  double _touchY = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (size.width == 0 || size.height == 0) return;
    setState(() {
      _isDragging = true;
      _touchX = ((details.localPosition.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
      _touchY = ((details.localPosition.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);
    });
  }

  void _onPanEnd() {
    setState(() {
      _isDragging = false;
      _touchX = 0.0;
      _touchY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 240);

        return GestureDetector(
          onPanUpdate: (details) => _onPanUpdate(details, size),
          onPanEnd: (_) => _onPanEnd(),
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final t = _animController.value;
              final idleTiltX = math.sin(t * 2 * math.pi) * 0.12;
              final idleTiltY = math.cos(t * 2 * math.pi) * 0.15;

              final targetRotX = _isDragging ? -_touchY * 0.35 : idleTiltX;
              final targetRotY = _isDragging ? _touchX * 0.40 : idleTiltY;

              return SizedBox(
                width: double.infinity,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Dynamic 3D Sound Frequency Waves
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SonicSpherePainter(
                          progress: t,
                          rotX: targetRotX,
                          rotY: targetRotY,
                        ),
                      ),
                    ),

                    // Central 3D Levitation Core Sphere with Microphone
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateX(targetRotX)
                        ..rotateY(targetRotY)
                        ..rotateZ(math.sin(t * 2 * math.pi) * 0.05),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            center: Alignment(-0.35, -0.35),
                            radius: 0.85,
                            colors: [
                              Color(0xFF38BDF8),
                              Color(0xFF6366F1),
                              Color(0xFF1E1B4B),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                              blurRadius: 36,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                    ),

                    // Floating Speech Chip 1: Kannada (Z: 45)
                    Positioned(
                      top: 24 + math.sin(t * 2 * math.pi + 1.2) * 8,
                      left: 20,
                      child: _buildSpeechBubble(
                        text: 'ಕನ್ನಡದಲ್ಲಿ ಕಲಿಯಿರಿ 🇮🇳',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),

                    // Floating Speech Chip 2: English (Z: 35)
                    Positioned(
                      top: 40 + math.cos(t * 2 * math.pi + 2.5) * 8,
                      right: 18,
                      child: _buildSpeechBubble(
                        text: 'Explain in English 🇬🇧',
                        color: const Color(0xFF10B981),
                      ),
                    ),

                    // Floating Speech Chip 3: Voice AI Active
                    Positioned(
                      bottom: 18 + math.sin(t * 2 * math.pi + 3.8) * 8,
                      child: _buildSpeechBubble(
                        text: 'Ask Anything with Voice 🎙️',
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSpeechBubble({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SonicSpherePainter extends CustomPainter {
  final double progress;
  final double rotX;
  final double rotY;

  _SonicSpherePainter({
    required this.progress,
    required this.rotX,
    required this.rotY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Multiple 3D Soundwave Rings expanding outward
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + i * 0.33) % 1.0;
      final radius = 55.0 + ringProgress * 65.0;
      final alpha = (1.0 - ringProgress) * 0.4;

      final wavePaint = Paint()
        ..color = const Color(0xFF06B6D4).withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 - (ringProgress * 1.2);

      canvas.save();
      canvas.translate(center.dx + rotY * 20, center.dy + rotX * 20);
      canvas.scale(1.0, 0.48); // 3D perspective slant
      canvas.drawCircle(Offset.zero, radius, wavePaint);
      canvas.restore();
    }

    // Orbiting Sound Wave Bars
    final barCount = 18;
    final barPaint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.7)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < barCount; i++) {
      final angle = (i / barCount) * 2 * math.pi + progress * 2 * math.pi;
      final distance = 78.0;
      final height = 10.0 + math.sin(angle * 3 + progress * 4 * math.pi).abs() * 16.0;

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance * 0.45;

      canvas.drawLine(
        Offset(x, y - height / 2),
        Offset(x, y + height / 2),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SonicSpherePainter oldDelegate) => true;
}

// ============================================================================
// 3. PAGE 3: 3D GAMIFIED TROPHY & GROWTH STREAK HELIX VISUAL
// Revolving 3D Gold Trophy, XP badges orbiting in 3D ellipses, particle spark
// shower, and interactive spring rotation.
// ============================================================================

class GrowthStreak3DVisual extends StatefulWidget {
  const GrowthStreak3DVisual({super.key});

  @override
  State<GrowthStreak3DVisual> createState() => _GrowthStreak3DVisualState();
}

class _GrowthStreak3DVisualState extends State<GrowthStreak3DVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  double _touchX = 0.0;
  double _touchY = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (size.width == 0 || size.height == 0) return;
    setState(() {
      _isDragging = true;
      _touchX = ((details.localPosition.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
      _touchY = ((details.localPosition.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);
    });
  }

  void _onPanEnd() {
    setState(() {
      _isDragging = false;
      _touchX = 0.0;
      _touchY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 240);

        return GestureDetector(
          onPanUpdate: (details) => _onPanUpdate(details, size),
          onPanEnd: (_) => _onPanEnd(),
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final t = _animController.value;
              final idleTiltX = math.sin(t * 2 * math.pi) * 0.10;
              final idleTiltY = math.cos(t * 2 * math.pi) * 0.18;

              final targetRotX = _isDragging ? -_touchY * 0.35 : idleTiltX;
              final targetRotY = _isDragging ? _touchX * 0.45 : idleTiltY;

              return SizedBox(
                width: double.infinity,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Ambient Trophy Gold Glow
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                                blurRadius: 65,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Orbiting XP Ring and Spark Particles
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GrowthOrbitPainter(
                          progress: t,
                          rotX: targetRotX,
                          rotY: targetRotY,
                        ),
                      ),
                    ),

                    // 3D Interactive Trophy Platform
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0018)
                        ..rotateX(targetRotX)
                        ..rotateY(targetRotY)
                        ..rotateZ(math.sin(t * 2 * math.pi) * 0.06),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            center: Alignment(-0.3, -0.3),
                            radius: 0.8,
                            colors: [
                              Color(0xFFFDE047),
                              Color(0xFFF59E0B),
                              Color(0xFFB45309),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFFEF08A),
                            width: 3.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                              blurRadius: 36,
                              offset: Offset(-targetRotY * 25, targetRotX * 25 + 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    ),

                    // Orbiting Badge 1: Streak 🔥 (Z: 40)
                    Positioned(
                      top: 26 + math.sin(t * 2 * math.pi + 0.8) * 8,
                      right: 22,
                      child: _buildAchievementPill(
                        icon: Icons.local_fire_department_rounded,
                        text: '7 Day Streak 🔥',
                        color: const Color(0xFFEF4444),
                      ),
                    ),

                    // Orbiting Badge 2: +50 XP (Z: 45)
                    Positioned(
                      bottom: 25 + math.cos(t * 2 * math.pi + 2.2) * 8,
                      left: 24,
                      child: _buildAchievementPill(
                        icon: Icons.star_rounded,
                        text: '+50 XP Earned ⭐',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),

                    // Orbiting Badge 3: Level Up (Z: 50)
                    Positioned(
                      top: 30 + math.cos(t * 2 * math.pi + 3.8) * 8,
                      left: 20,
                      child: _buildAchievementPill(
                        icon: Icons.trending_up_rounded,
                        text: 'Level Up 🚀',
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAchievementPill({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthOrbitPainter extends CustomPainter {
  final double progress;
  final double rotX;
  final double rotY;

  _GrowthOrbitPainter({
    required this.progress,
    required this.rotX,
    required this.rotY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 3D Elliptical Golden Orbit Ring
    final orbitPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.save();
    canvas.translate(center.dx + rotY * 15, center.dy + rotX * 15);
    canvas.rotate(-math.pi / 8);
    canvas.scale(1.0, 0.42);
    canvas.drawCircle(Offset.zero, 110, orbitPaint);

    // Orbiting Star Planet
    final starPaint = Paint()..color = const Color(0xFFFDE047);
    final angle = progress * 2 * math.pi;
    final starX = math.cos(angle) * 110;
    final starY = math.sin(angle) * 110;
    canvas.drawCircle(Offset(starX, starY), 5.5, starPaint);
    canvas.restore();

    // Floating Rising Spark Particles
    final sparkPaint = Paint()..color = const Color(0xFFFEF08A);
    final random = math.Random(42);
    for (int i = 0; i < 10; i++) {
      final particleProgress = (progress + (i / 10)) % 1.0;
      final startX = center.dx + (random.nextDouble() * 140 - 70);
      final y = center.dy + 80 - (particleProgress * 150);
      final alpha = math.sin(particleProgress * math.pi) * 0.7;

      sparkPaint.color = const Color(0xFFFDE047).withValues(alpha: alpha);
      canvas.drawCircle(Offset(startX, y), 2.2, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthOrbitPainter oldDelegate) => true;
}
