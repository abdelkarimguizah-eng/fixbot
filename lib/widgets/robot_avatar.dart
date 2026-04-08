import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// RobotAvatar — renders the FixBot SVG mascot.
///
/// Using SVG gives you:
///   ✅ No background (transparent)
///   ✅ Crisp at any size (vector)
///   ✅ Animatable via Transform wrappers
///   ✅ Tiny file size vs PNG
///
/// To swap: just replace lib/assets/images/robot.svg
/// No code changes needed.

class RobotAvatar extends StatelessWidget {
  final double size;
  const RobotAvatar({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'lib/assets/images/robot.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
