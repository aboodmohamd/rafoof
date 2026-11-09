import 'package:flutter/material.dart';
import 'package:rafoof/core/theme/app_colors.dart';

class SkeletonBox extends StatefulWidget {
  final AppColors colors;
  final double? width;
  final double? height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.colors,
    this.width,
    this.height,
    this.radius = 12,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.45, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.colors.border,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
