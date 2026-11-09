import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FlyToCart extends StatefulWidget {
  final String imageUrl;
  final Rect start;
  final Rect end;
  final VoidCallback onComplete;

  const FlyToCart({
    super.key,
    required this.imageUrl,
    required this.start,
    required this.end,
    required this.onComplete,
  });

  static void run({
    required BuildContext context,
    required String imageUrl,
    required GlobalKey startKey,
    required GlobalKey endKey,
  }) {
    final start = _rectOf(startKey);
    final end = _rectOf(endKey);
    if (start == null || end == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => FlyToCart(
        imageUrl: imageUrl,
        start: start,
        end: end,
        onComplete: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
  }

  static Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  State<FlyToCart> createState() => _FlyToCartState();
}

class _FlyToCartState extends State<FlyToCart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startCenter = widget.start.center;
    final endCenter = widget.end.center;
    final control = Offset(
      (startCenter.dx + endCenter.dx) / 2,
      min(startCenter.dy, endCenter.dy) - 90,
    );
    final startSize = min(widget.start.shortestSide * 0.7, 180.0);
    final endSize = widget.end.shortestSide * 0.7;

    return IgnorePointer(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final t = _animation.value;
              final position =
                  startCenter * ((1 - t) * (1 - t)) +
                  control * (2 * (1 - t) * t) +
                  endCenter * (t * t);
              final size = lerpDouble(startSize, endSize, t)!;

              return Positioned(
                left: position.dx - size / 2,
                top: position.dy - size / 2,
                width: size,
                height: size,
                child: Transform.rotate(
                  angle: t * 0.45,
                  child: Opacity(opacity: 1 - t * 0.3, child: child),
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
