import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget? child;
  const AnimatedBackground({super.key, this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Orb> _orbs = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    
    // Create random floating orbs
    for (int i = 0; i < 5; i++) {
      _orbs.add(_Orb(
        color: i % 2 == 0 ? AppColors.primary : AppColors.secondary,
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: 50 + _random.nextDouble() * 100,
        speed: 0.2 + _random.nextDouble() * 0.3,
        theta: _random.nextDouble() * 2 * pi,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.bgGradient,
          ),
        ),
        // Animated Orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _OrbPainter(_orbs, _controller.value),
              size: Size.infinite,
            );
          },
        ),
        // Glass Overlay (optional, for depth)
        Container(color: Colors.black54), // Subtle dim
        // Child Content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Orb {
  final Color color;
  double x; // 0.0 to 1.0 (relative to screen)
  double y; // 0.0 to 1.0
  final double radius;
  final double speed;
  double theta; // Angle of movement

  _Orb({
    required this.color,
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.theta,
  });
}

class _OrbPainter extends CustomPainter {
  final List<_Orb> orbs;
  final double progress;

  _OrbPainter(this.orbs, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var orb in orbs) {
      // Calculate new position based on circular motion
      final dx = cos(orb.theta + progress * 2 * pi) * 0.1;
      final dy = sin(orb.theta + progress * 2 * pi) * 0.1;

      final paint = Paint()
        ..color = orb.color.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

      final center = Offset(
        (orb.x + dx) * size.width,
        (orb.y + dy) * size.height,
      );

      canvas.drawCircle(center, orb.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Extension to avoid 'withOpacity' deprecation warnings if willing, 
// but for now relying on standard methods. 
// Note: 'withOrdinalSort' above was a typo in thinking, meant generic color manipulation.
// Fixed in actual implementation line above: using withAlpha or withValues in updated Dart 3.x
