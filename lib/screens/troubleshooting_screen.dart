import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/robot_avatar.dart';

class TroubleshootingScreen extends ConsumerStatefulWidget {
  final String equipment;
  final String brand;
  final String model;

  const TroubleshootingScreen({
    super.key,
    required this.equipment,
    required this.brand,
    required this.model,
  });

  @override
  ConsumerState<TroubleshootingScreen> createState() =>
      _TroubleshootingScreenState();
}

class _TroubleshootingScreenState
    extends ConsumerState<TroubleshootingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final issues =
        ref.watch(troubleshootingIssuesProvider(widget.equipment));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Column(
        children: [
          _buildHeader(context, w, h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                  w * 0.04, w * 0.04, w * 0.04, h * 0.14),
              children: [
                ...issues.asMap().entries.map((entry) {
                  final index = entry.key;
                  final issue = entry.value;
                  return _AnimatedIssueCard(
                    index: index,
                    issue: issue,
                    controller: _listController,
                    onTap: () {
                      ref
                          .read(diagnosisProvider.notifier)
                          .selectProblem(issue.title);
                      context.go('/chat', extra: {
                        'equipment': widget.equipment,
                        'brand': widget.brand,
                        'model': widget.model,
                        'problem': issue.title,
                      });
                    },
                  );
                }),
              
                _TipCard(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _FixBotFab(
        onTap: () => context.go('/chat', extra: {
          'equipment': widget.equipment,
          'brand': widget.brand,
          'model': widget.model,
          'problem': '',
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double w, double h) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2B547A), Color(0xFF436286)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(w * 0.05, 14, w * 0.05, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              GestureDetector(
                onTap: () => context.go('/equipment'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.18),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Troubleshooting',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.equipment,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.80),
                      ),
                    ),
                    Text(
                      '${widget.brand} · ${widget.model}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.62),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedIssueCard extends StatelessWidget {
  final int index;
  final TroubleshootingIssue issue;
  final AnimationController controller;
  final VoidCallback onTap;

  const _AnimatedIssueCard({
    required this.index,
    required this.issue,
    required this.controller,
    required this.onTap,
  });

  Color get _dotColor {
    switch (issue.priority) {
      case 'high': return AppColors.highPriority;
      case 'medium': return AppColors.mediumPriority;
      default: return AppColors.lowPriority;
    }
  }

  IconData get _icon {
    switch (issue.priority) {
      case 'high': return Icons.warning_amber_rounded;
      case 'medium': return Icons.error_outline_rounded;
      default: return Icons.check_circle_outline_rounded;
    }
  }

  String get _priorityLabel {
    switch (issue.priority) {
      case 'high': return 'High Priority';
      case 'medium': return 'Medium Priority';
      default: return 'Low Priority';
    }
  }

  @override
  Widget build(BuildContext context) {
    final delay = index * 0.12;
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(delay.clamp(0.0, 0.8), (delay + 0.4).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    final slideAnim =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
            .animate(animation);
    final fadeAnim = animation;

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: fadeAnim,
        child: _IssueCardContent(
          issue: issue,
          dotColor: _dotColor,
          icon: _icon,
          priorityLabel: _priorityLabel,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _IssueCardContent extends StatefulWidget {
  final TroubleshootingIssue issue;
  final Color dotColor;
  final IconData icon;
  final String priorityLabel;
  final VoidCallback onTap;

  const _IssueCardContent({
    required this.issue,
    required this.dotColor,
    required this.icon,
    required this.priorityLabel,
    required this.onTap,
  });

  @override
  State<_IssueCardContent> createState() => _IssueCardContentState();
}

class _IssueCardContentState extends State<_IssueCardContent> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(
            horizontal: w * 0.045, vertical: w * 0.04),
        transform: Matrix4.identity()
          ..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFF0F4F8) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_pressed ? 0.04 : 0.08),
              blurRadius: _pressed ? 4 : 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            
            Container(
              width: w * 0.12,
              height: w * 0.12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.dotColor.withOpacity(0.10),
              ),
              child: Icon(widget.icon,
                  color: widget.dotColor, size: w * 0.065),
            ),
            SizedBox(width: w * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.issue.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: w * 0.042,
                      color: AppColors.darkAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.dotColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.priorityLabel,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: w * 0.030,
                          color: widget.dotColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.neutralGrey, size: 22),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: AppColors.tipBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.tipBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              color: AppColors.primaryBlue, size: w * 0.055),
          SizedBox(width: w * 0.035),
          Expanded(
            child: Text(
              'Tap an issue above to get step-by-step guidance from FixBot.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: w * 0.032,
                color: AppColors.primaryBlue,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FixBotFab extends StatefulWidget {
  final VoidCallback onTap;
  const _FixBotFab({required this.onTap});

  @override
  State<_FixBotFab> createState() => _FixBotFabState();
}

class _FixBotFabState extends State<_FixBotFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2B547A), Color(0xFF436286)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Center(
                child: RobotAvatar(size: 38),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.online,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
