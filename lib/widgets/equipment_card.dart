import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AnimatedEquipmentCard extends StatelessWidget {
  final int index;
  final String name;
  final String iconType;
  final AnimationController listController;
  final VoidCallback onTap;

  const AnimatedEquipmentCard({
    super.key,
    required this.index,
    required this.name,
    required this.iconType,
    required this.listController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final delay = index * 0.10;
    final anim = CurvedAnimation(
      parent: listController,
      curve: Interval(
        delay.clamp(0.0, 0.7),
        (delay + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    final slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
            .animate(anim);

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: anim,
        child: EquipmentCard(
          name: name,
          iconType: iconType,
          onTap: onTap,
        ),
      ),
    );
  }
}

class EquipmentCard extends StatefulWidget {
  final String name;
  final String iconType;
  final VoidCallback onTap;

  const EquipmentCard({
    super.key,
    required this.name,
    required this.iconType,
    required this.onTap,
  });

  @override
  State<EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends State<EquipmentCard> {
  bool _pressed = false;

  IconData get _icon {
    switch (widget.iconType) {
      case 'motor':
        return Icons.electric_bolt_rounded;
      case 'actuator':
        return Icons.settings_input_component_rounded;
      case 'plc':
        return Icons.memory_rounded;
      case 'sensor':
        return Icons.sensors_rounded;
      case 'variator':
        return Icons.tune_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  Color get _accentColor {
    switch (widget.iconType) {
      case 'motor':
      case 'actuator':
      case 'plc':
      case 'sensor':
      case 'variator':
        return const Color(0xFF2B547A);
      default:
        return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width / 2;
        final iconSize = (cardWidth * 0.38).clamp(56.0, 84.0).toDouble();
        final titleSize = (cardWidth * 0.15).clamp(15.0, 20.0).toDouble();
        final spacing = (cardWidth * 0.08).clamp(8.0, 16.0).toDouble();

        return GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            transform: Matrix4.identity()..scale(_pressed ? 0.95 : 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: _pressed ? const Color(0xFFF5F7FA) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(_pressed ? 0.06 : 0.12),
                  blurRadius: _pressed ? 6 : 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accentColor.withOpacity(0.09),
                  ),
                  child: Icon(
                    _icon,
                    color: _accentColor,
                    size: iconSize * 0.52,
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  widget.name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                    color: AppColors.darkAccent,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: (spacing * 0.45).clamp(4.0, 8.0).toDouble()),
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
