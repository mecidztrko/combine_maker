import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 * pi;
        final size = MediaQuery.of(context).size;
        Color c1 = Colors.green.shade50;
        Color c2 = Colors.white;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c1, c2],
            ),
          ),
          child: Stack(
            children: [
              _AnimatedBlob(
                color: Colors.green.shade100,
                left: size.width * (0.15 + 0.05 * sin(t)),
                top: size.height * (0.10 + 0.03 * cos(t * 1.3)),
                diameter: size.shortestSide * 0.45,
              ),
              _AnimatedBlob(
                color: Colors.teal.shade100.withOpacity(.8),
                left: size.width * (0.65 + 0.06 * cos(t * 0.8)),
                top: size.height * (0.20 + 0.05 * sin(t * 1.1)),
                diameter: size.shortestSide * 0.50,
              ),
              _AnimatedBlob(
                color: Colors.green.shade200.withOpacity(.6),
                left: size.width * (0.30 + 0.07 * sin(t * 0.9)),
                top: size.height * (0.65 + 0.04 * cos(t * 1.4)),
                diameter: size.shortestSide * 0.55,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.white.withOpacity(0.2)),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final double left;
  final double top;
  final double diameter;
  final Color color;
  const _AnimatedBlob({required this.left, required this.top, required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}


