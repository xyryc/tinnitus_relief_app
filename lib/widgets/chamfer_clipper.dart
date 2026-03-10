import 'package:flutter/material.dart';

class ChamferClipper extends CustomClipper<Path> {
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  ChamferClipper({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  @override
  Path getClip(Size s) {
    final p = Path();
    p.moveTo(topLeft, 0);
    p.lineTo(s.width - topRight, 0);
    p.lineTo(s.width, topRight);
    p.lineTo(s.width, s.height - bottomRight);
    p.lineTo(s.width - bottomRight, s.height);
    p.lineTo(bottomLeft, s.height);
    p.lineTo(0, s.height - bottomLeft);
    p.lineTo(0, topLeft);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant ChamferClipper oldClipper) {
    return topLeft != oldClipper.topLeft ||
        topRight != oldClipper.topRight ||
        bottomLeft != oldClipper.bottomLeft ||
        bottomRight != oldClipper.bottomRight;
  }
}
