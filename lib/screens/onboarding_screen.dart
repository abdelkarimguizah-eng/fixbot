import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/robot_avatar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _bubbleController;
  late AnimationController _buttonController;
  late Animation<double> _floatY;
  late Animation<double> _bubbleScale;
  late Animation<double> _bubbleOpacity;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _floatController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _bubbleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _buttonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _floatY = Tween<double>(begin: -10, end: 10).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _bubbleScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _bubbleController, curve: Curves.easeOutBack));
    _bubbleOpacity = CurvedAnimation(
        parent: _bubbleController, curve: Curves.easeIn);

    _buttonOpacity = CurvedAnimation(
        parent: _buttonController, curve: Curves.easeIn);
    _buttonSlide = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _buttonController, curve: Curves.easeOutCubic));

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _bubbleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _bubbleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth =
                constraints.maxWidth.clamp(0.0, 460.0).toDouble();
            final avatarSize = (contentWidth * 0.42).clamp(140.0, 190.0).toDouble();
            final horizontalPadding = contentWidth < 380 ? 20.0 : 28.0;
            final bubbleTitleSize =
                (contentWidth * 0.052).clamp(22.0, 28.0).toDouble();
            final bubbleBodySize =
                (contentWidth * 0.035).clamp(14.0, 17.0).toDouble();
            final bubbleVerticalPadding =
                (constraints.maxHeight * 0.032).clamp(22.0, 34.0).toDouble();
            final sectionGap =
                (constraints.maxHeight * 0.045).clamp(24.0, 36.0).toDouble();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _floatY,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(0, _floatY.value),
                              child: child,
                            ),
                            child: RobotAvatar(size: avatarSize),
                          ),
                          SizedBox(height: sectionGap),
                          ScaleTransition(
                            scale: _bubbleScale,
                            child: FadeTransition(
                              opacity: _bubbleOpacity,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: bubbleVerticalPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2B547A).withOpacity(0.10),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.online,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'FixBot',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "I'll guide you step by step.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        fontSize: bubbleTitleSize,
                                        color: AppColors.darkAccent,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Select the equipment you want to diagnose\nand I\'ll help you find the problem.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: bubbleBodySize,
                                        color: Colors.black45,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          SlideTransition(
                            position: _buttonSlide,
                            child: FadeTransition(
                              opacity: _buttonOpacity,
                              child: _ContinueButton(
                                onTap: () => context.go('/equipment'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ContinueButton({required this.onTap});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
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
      onTapUp: (_) { _c.reverse(); widget.onTap(); },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2B547A), Color(0xFF436286)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Continue',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
