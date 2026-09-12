import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// A premium 3D perspective interactive card widget.
/// Features genuine Matrix4 3D tilting, dynamic specular light glare,
/// reactive depth shadows, idle breathing/levitation, and multi-layer parallax.
class Tilt3DCard extends StatefulWidget {
  final Widget child;
  final Widget? floatingBadge;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final double maxTiltAngle;
  final bool enableIdleFloat;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool showGlare;
  final double elevation;

  const Tilt3DCard({
    super.key,
    required this.child,
    this.floatingBadge,
    this.accentColor = AppColors.primary,
    this.backgroundColor = AppColors.surface,
    this.onTap,
    this.maxTiltAngle = 0.18,
    this.enableIdleFloat = true,
    this.borderRadius = 26.0,
    this.padding = const EdgeInsets.all(22.0),
    this.showGlare = true,
    this.elevation = 20.0,
  });

  @override
  State<Tilt3DCard> createState() => _Tilt3DCardState();
}

class _Tilt3DCardState extends State<Tilt3DCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  // Interaction coordinates normalized between -1.0 and 1.0
  double _touchX = 0.0;
  double _touchY = 0.0;
  bool _isInteracting = false;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    if (widget.enableIdleFloat) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    if (size.width == 0 || size.height == 0) return;

    // Convert local position into normalized -1.0 -> 1.0 space
    final normalizedX = (details.localPosition.dx / size.width) * 2 - 1.0;
    final normalizedY = (details.localPosition.dy / size.height) * 2 - 1.0;

    setState(() {
      _isInteracting = true;
      _scale = 1.025;
      _touchX = normalizedX.clamp(-1.0, 1.0);
      _touchY = normalizedY.clamp(-1.0, 1.0);
    });
  }

  void _handlePanEnd() {
    setState(() {
      _isInteracting = false;
      _scale = 1.0;
      _touchX = 0.0;
      _touchY = 0.0;
    });
  }

  void _handleHover(PointerEvent event, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final normalizedX = (event.localPosition.dx / size.width) * 2 - 1.0;
    final normalizedY = (event.localPosition.dy / size.height) * 2 - 1.0;

    setState(() {
      _isInteracting = true;
      _scale = 1.02;
      _touchX = normalizedX.clamp(-1.0, 1.0);
      _touchY = normalizedY.clamp(-1.0, 1.0);
    });
  }

  void _handleHoverExit() {
    setState(() {
      _isInteracting = false;
      _scale = 1.0;
      _touchX = 0.0;
      _touchY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSize = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 300,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 200,
        );

        return MouseRegion(
          onHover: (e) => _handleHover(e, cardSize),
          onExit: (_) => _handleHoverExit(),
          child: GestureDetector(
            onPanStart: (_) => setState(() {
              _isInteracting = true;
              _scale = 1.025;
            }),
            onPanUpdate: (details) => _handlePanUpdate(details, cardSize),
            onPanEnd: (_) => _handlePanEnd(),
            onPanCancel: _handlePanEnd,
            onTap: widget.onTap,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                // Calculate rotational angle
                double rotX;
                double rotY;

                if (_isInteracting) {
                  // Interactive touch response
                  rotX = -_touchY * widget.maxTiltAngle;
                  rotY = _touchX * widget.maxTiltAngle;
                } else if (widget.enableIdleFloat) {
                  // Gentle floating oscillation
                  final progress = _animController.value * 2 * math.pi;
                  rotX = math.sin(progress) * (widget.maxTiltAngle * 0.28);
                  rotY = math.cos(progress * 0.8) * (widget.maxTiltAngle * 0.22);
                } else {
                  rotX = 0.0;
                  rotY = 0.0;
                }

                // Dynamic shadow offsets opposite the tilt direction
                final shadowDx = -rotY * 45;
                final shadowDy = rotX * 45 + (_isInteracting ? 14 : 8);

                // Build 3D Matrix
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.0012) // Optical perspective
                  ..rotateX(rotX)
                  ..rotateY(rotY)
                  ..scaleByDouble(_scale, _scale, _scale, 1.0);

                // Specular light coordinates
                final glareAlignment = Alignment(
                  (_touchX * 1.5).clamp(-1.0, 1.0),
                  (_touchY * 1.5).clamp(-1.0, 1.0),
                );

                return Transform(
                  transform: transform,
                  alignment: FractionalOffset.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Base Card with Glassmorphic gradient & neon borders
                      Container(
                        padding: widget.padding,
                        decoration: BoxDecoration(
                          color: widget.backgroundColor,
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.accentColor.withValues(alpha: _isInteracting ? 0.20 : 0.12),
                              widget.backgroundColor,
                              widget.backgroundColor.withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                          border: Border.all(
                            color: _isInteracting
                                ? widget.accentColor.withValues(alpha: 0.75)
                                : widget.accentColor.withValues(alpha: 0.35),
                            width: _isInteracting ? 1.8 : 1.2,
                          ),
                          boxShadow: [
                            // Ambient accent glow
                            BoxShadow(
                              color: widget.accentColor.withValues(
                                alpha: _isInteracting ? 0.32 : 0.14,
                              ),
                              blurRadius: _isInteracting ? 34 : 22,
                              spreadRadius: _isInteracting ? 2 : 0,
                              offset: Offset(shadowDx * 0.5, shadowDy * 0.5),
                            ),
                            // Deep black grounding shadow
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 28,
                              offset: Offset(shadowDx, shadowDy),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Child Content
                            widget.child,

                            // Dynamic Specular Light Glare
                            if (widget.showGlare)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(widget.borderRadius),
                                      gradient: RadialGradient(
                                        center: glareAlignment,
                                        radius: 1.2,
                                        colors: [
                                          Colors.white.withValues(
                                            alpha: _isInteracting ? 0.16 : 0.05,
                                          ),
                                          Colors.white.withValues(alpha: 0.0),
                                        ],
                                        stops: const [0.0, 0.65],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Multi-Layer Elevated 3D Parallax Badge
                      if (widget.floatingBadge != null)
                        Positioned(
                          top: -14,
                          right: 18,
                          child: Transform.translate(
                            offset: Offset(
                              rotY * 40,
                              -rotX * 40,
                            ),
                            child: widget.floatingBadge!,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
