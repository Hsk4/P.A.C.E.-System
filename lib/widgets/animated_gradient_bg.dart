import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AnimatedGradientBg extends StatefulWidget {
  final Widget child;
  final Color primaryColor;

  const AnimatedGradientBg({
    super.key,
    required this.child,
    this.primaryColor = AppTheme.accent,
  });

  @override
  State<AnimatedGradientBg> createState() => _AnimatedGradientBgState();
}

class _AnimatedGradientBgState extends State<AnimatedGradientBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.lerp(
              const Alignment(-0.5, -0.5),
              const Alignment(0.5, 0.5),
              _animation.value,
            )!,
            radius: 1.2,
            colors: [
              widget.primaryColor.withOpacity(0.08),
              AppTheme.bg,
            ],
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
