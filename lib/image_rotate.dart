import 'package:flutter/material.dart';
import 'dart:math' as math;

class ImageRotate extends StatefulWidget {
  const ImageRotate({super.key});

  @override
  State<ImageRotate> createState() => _ImageRotateState();
}

class _ImageRotateState extends State<ImageRotate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(seconds: 2))
        ..repeat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          );
        },
        child: const FlutterLogo(size: 120),
      ),
    );
  }
}
