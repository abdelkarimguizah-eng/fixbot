import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/robot_avatar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String equipment;
  final String brand;
  final String model;
  final String problem;

  const ChatScreen({
    super.key,
    required this.equipment,
    required this.brand,
    required this.model,
    required this.problem,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;
  bool _inputFocused = false;
  late AnimationController _headerPulse;
  late Animation<double> _headerGlow;

  @override
  void initState() {
    super.initState();
    _headerPulse = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _headerGlow = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _headerPulse, curve: Curves.easeInOut));

    _focusNode.addListener(() {
      setState(() => _inputFocused = _focusNode.hasFocus);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _initChat());
  }

  void _initChat() {
    final notifier = ref.read(diagnosisProvider.notifier);
    final greeting = widget.problem.isNotEmpty
        ? 'Hello! I\'m FixBot 👋\n\nYou selected **${widget.problem}** on your ${widget.brand} ${widget.model}.\n\nIs this happening continuously or only sometimes?'
        : 'Hello! I\'m FixBot 👋\n\nDescribe the problem you\'re experiencing with your ${widget.brand} ${widget.model} and I\'ll guide you through diagnosing it step by step.';
    notifier.addMessage(
        ChatMessage(text: greeting, isUser: false, timestamp: DateTime.now()));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _headerPulse.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final notifier = ref.read(diagnosisProvider.notifier);
    notifier.addMessage(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
    _inputController.clear();
    setState(() => _isTyping = true);
    _scrollToBottom();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    notifier.addMessage(ChatMessage(
        text: _generateResponse(text),
        isUser: false,
        timestamp: DateTime.now()));
    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  String _generateResponse(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('continuously') ||
        lower.contains('always') ||
        lower.contains('constant')) {
      return 'Continuous issues usually point to a persistent fault.\n\n**Possible causes:**\n• Motor overloaded beyond rated capacity\n• Cooling system failure or blocked vents\n• Bearing wear or misalignment\n\n**Steps to follow:**\n1. Check current draw vs nameplate rating\n2. Inspect cooling vents for blockages\n3. Listen for abnormal bearing noise\n\nDo you see any error codes on the panel?';
    }
    if (lower.contains('intermittent') || lower.contains('sometimes')) {
      return 'Intermittent issues often relate to thermal or electrical conditions.\n\n**Likely causes:**\n• Thermal overload tripping under heavy load\n• Loose electrical connections\n• Supply voltage fluctuations\n\nDoes it happen more under heavy load or at startup?';
    }
    if (lower.contains('hot') ||
        lower.contains('heat') ||
        lower.contains('temperature')) {
      return 'Overheating is a serious concern.\n\n1. **Ambient temperature** — should be below 40°C\n2. **Duty cycle** — running too long without rest\n3. **Ventilation** — clean any dust from vents\n4. **Load** — verify you\'re not exceeding rated torque\n\nWhat is the current temperature reading?';
    }
    return 'Thank you for the information.\n\n**Recommended steps:**\n1. Visual inspection for obvious damage\n2. Measure operating temperature and current\n3. Check maintenance log for recent changes\n\nCan you share more details about when the issue started?';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final messages = ref.watch(diagnosisProvider).messages;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F6),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildHeader(context, w),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(w * 0.04, 16, w * 0.04, 8),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && _isTyping) {
                  return const _TypingBubble();
                }
                return _ChatBubble(message: messages[index], index: index);
              },
            ),
          ),
          _buildActionRow(context, w),
          _buildInputBar(context, w),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double w) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A5F), Color(0xFF2B547A), Color(0xFF3A6B94)],
        ),
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(w * 0.04, 12, w * 0.04, 18),
          child: Row(
            children: [
            
              _HeaderIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.go('/troubleshooting', extra: {
                  'equipment': widget.equipment,
                  'brand': widget.brand,
                  'model': widget.model,
                }),
              ),
              const SizedBox(width: 12),
              AnimatedBuilder(
                animation: _headerGlow,
                builder: (_, child) => Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                    border: Border.all(
                      color:
                          Colors.white.withOpacity(_headerGlow.value * 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentBlue
                            .withOpacity(_headerGlow.value * 0.4),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: Stack(
                  children: [
                    const Center(child: RobotAvatar(size: 36)),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.online,
                          border: Border.all(
                              color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FixBot Assistant',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.online,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Online · AI Troubleshooting',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: Text(
                  widget.equipment,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, double w) {
    return Container(
      color: const Color(0xFFEFF2F6),
      padding: EdgeInsets.fromLTRB(w * 0.04, 6, w * 0.04, 4),
      child: Column(
        children: [
          Text(
            'Was this solution helpful?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Colors.black.withOpacity(0.38),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionChip(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                color: const Color(0xFF49B65F),
                onTap: () {},
              ),
              SizedBox(width: w * 0.03),
              _ActionChip(
                label: 'Done',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF5681D6),
                onTap: () => context.go('/equipment'),
              ),
              SizedBox(width: w * 0.03),
              _ActionChip(
                label: 'No',
                icon: Icons.cancel_outlined,
                color: const Color(0xFF900B09),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, double w) {
    return SafeArea(
      top: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(_inputFocused ? 0.10 : 0.05),
              blurRadius: _inputFocused ? 16 : 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(w * 0.04, 10, w * 0.04, 10),
        child: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(
                    color: _inputFocused
                        ? AppColors.primaryBlue.withOpacity(0.45)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _inputController,
                  focusNode: _focusNode,
                  onSubmitted: (_) => _sendMessage(),
                  textInputAction: TextInputAction.send,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: w * 0.038,
                    color: AppColors.darkAccent,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Describe the problem...',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: w * 0.035,
                      color: AppColors.neutralGrey,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    prefixIcon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.neutralGrey,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _SendButton(onTap: _sendMessage),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(_pressed ? 0.30 : 0.15),
        ),
        child: Icon(widget.icon, color: Colors.white, size: 17),
      ),
    );
  }
}

class _ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final int index;
  const _ChatBubble({required this.message, required this.index});

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    final isUser = widget.message.isUser;
    _slide = Tween<Offset>(
            begin: Offset(isUser ? 0.15 : -0.15, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isUser = widget.message.isUser;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            
              if (!isUser) ...[
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 8, bottom: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE0E9F4),
                    border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.25),
                        width: 1.5),

                  ),
                  child: const Center(child: RobotAvatar(size: 20)),
                ),
              ],
            
              Container(
                constraints: BoxConstraints(maxWidth: w * 0.70),
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.042, vertical: w * 0.030),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.primaryBlue
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isUser
                          ? AppColors.primaryBlue.withOpacity(0.25)
                          : Colors.black.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  widget.message.text,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: w * 0.036,
                    color: isUser ? Colors.white : AppColors.darkAccent,
                    height: 1.55,
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with TickerProviderStateMixin {
  final List<AnimationController> _dots = [];
  final List<Animation<double>> _dotY = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500));
      final a = Tween<double>(begin: 0.0, end: -6.0)
          .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
      _dots.add(c);
      _dotY.add(a);
      Future.delayed(Duration(milliseconds: i * 160),
          () => mounted ? c.repeat(reverse: true) : null);
    }
  }

  @override
  void dispose() {
    for (final c in _dots) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE0E9F4),
              border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.25), width: 1.5),
            ),
            child: const Center(child: RobotAvatar(size: 20)),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.05, vertical: w * 0.038),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _dotY[i],
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _dotY[i].value),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
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
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2B547A), Color(0xFF436286)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.40),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _ActionChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionChip(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        padding:
            EdgeInsets.symmetric(horizontal: w * 0.032, vertical: 8),
        transform: Matrix4.identity()..scale(_pressed ? 0.93 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _pressed
              ? widget.color.withOpacity(0.14)
              : widget.color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: widget.color.withOpacity(0.4), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: widget.color, size: 15),
            const SizedBox(width: 5),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: w * 0.030,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}