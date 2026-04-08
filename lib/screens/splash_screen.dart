import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../theme/app_theme.dart';
import '../widgets/robot_avatar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _robotController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late AnimationController _floatController;
  late AnimationController _particleController;

  late Animation<double> _robotScale;
  late Animation<double> _robotOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _buttonScale;
  late Animation<double> _buttonOpacity;
  late Animation<double> _floatY;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _robotController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _buttonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _particleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();

    _robotScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _robotController, curve: Curves.elasticOut));
    _robotOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _robotController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _textController, curve: Curves.easeOutCubic));
    _textOpacity =
        CurvedAnimation(parent: _textController, curve: Curves.easeIn);

    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
            parent: _buttonController, curve: Curves.easeOutBack));
    _buttonOpacity =
        CurvedAnimation(parent: _buttonController, curve: Curves.easeIn);

    _floatY = Tween<double>(begin: -8, end: 8).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _robotController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _robotController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _floatController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.45, 1.0],
            colors: [
              Color(0xFF1E3A5F),
              Color(0xFF2B547A),
              Color(0xFF001D35),
            ],
          ),
        ),
        child: Stack(
          children: [
            
            AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _ParticlePainter(_particleController.value),
              ),
            ),
            
            _GlowOrb(
                left: w * 0.05, top: h * 0.07, radius: 55, opacity: 0.10),
            _GlowOrb(right: 0, top: h * 0.25, radius: 45, opacity: 0.07),
            _GlowOrb(
                left: 0, bottom: h * 0.20, radius: 80, opacity: 0.09),

            
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  
                  AnimatedBuilder(
                    animation: _floatY,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _floatY.value),
                      child: child,
                    ),
                    child: ScaleTransition(
                      scale: _robotScale,
                      child: FadeTransition(
                        opacity: _robotOpacity,
                        child: Center(child: RobotAvatar(size: w * 0.56)),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: w * 0.10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [Colors.white, Color(0xFFB8D4F0)],
                              ).createShader(bounds),
                              child: Text(
                                'Welcome to FixBot',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  fontSize: w * 0.068,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            SizedBox(height: h * 0.014),
                            Text(
                              'Your AI assistant for diagnosing\nindustrial equipment problems',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: w * 0.036,
                                color: Colors.white.withOpacity(0.62),
                                height: 1.65,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  
                  ScaleTransition(
                    scale: _buttonScale,
                    child: FadeTransition(
                      opacity: _buttonOpacity,
                      child: Center(
                        child: _PressableButton(
                          label: 'Start Diagnosis',
                          width: w * 0.62,
                          onTap: () => context.go('/onboarding'),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _PressableButton extends StatefulWidget {
  final String label;
  final double width;
  final VoidCallback onTap;
  const _PressableButton(
      {required this.label, required this.width, required this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFF5B9BD5).withOpacity(0.35),
                blurRadius: 28,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.primaryBlue, size: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _GlowOrb extends StatelessWidget {
  final double? left, right, top, bottom;
  final double radius, opacity;
  const _GlowOrb(
      {this.left,
      this.right,
      this.top,
      this.bottom,
      required this.radius,
      required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity * 0.25),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(opacity),
              blurRadius: radius * 1.6,
              spreadRadius: radius * 0.2,
            ),
          ],
        ),
      ),
    );
  }
}


class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    for (int i = 0; i < 24; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.25 + rng.nextDouble() * 0.6;
      final y =
          (baseY - progress * speed * size.height * 0.35) % size.height;
      final r = 1.0 + rng.nextDouble() * 2.2;
      final op = 0.08 + rng.nextDouble() * 0.28;
      canvas.drawCircle(
          Offset(x, y), r, Paint()..color = Colors.white.withOpacity(op));
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
