import 'package:flutter/material.dart';

class PlayButtonPainter extends CustomPainter {
  final bool isPlaying;

  const PlayButtonPainter({required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final outerPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.12)
      ..lineTo(size.width * 0.12, size.height * 0.88)
      ..lineTo(size.width * 0.88, size.height * 0.5)
      ..close();

    canvas.drawPath(outerPath.shift(const Offset(4, 4)), shadowPaint);

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF49FF70),
          Color(0xFF03E74E),
          Color(0xFF0D9E36),
        ],
      ).createShader(Offset.zero & size);

    final strokePaint = Paint()
      ..color = const Color(0xFF9BB0B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(outerPath, fillPaint);
    canvas.drawPath(outerPath, strokePaint);

    if (isPlaying) {
      final barPaint = Paint()
        ..color = const Color(0xFF073013)
        ..style = PaintingStyle.fill;
      final leftBar = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.38, size.height * 0.33, 10, size.height * 0.34),
        const Radius.circular(2),
      );
      final rightBar = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.53, size.height * 0.33, 10, size.height * 0.34),
        const Radius.circular(2),
      );
      canvas.drawRRect(leftBar, barPaint);
      canvas.drawRRect(rightBar, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PlayButtonPainter oldDelegate) {
    return oldDelegate.isPlaying != isPlaying;
  }
}

class MetalThumbShape extends SliderComponentShape {
  const MetalThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(16, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = Rect.fromCenter(center: center, width: 16, height: 24);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2.5));
    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFD6D9DB),
          Color(0xFF7C8085),
          Color(0xFFE4E6E7),
        ],
      ).createShader(rect);
    final groove = Paint()..color = const Color(0xFF7E8388);
    final outline = Paint()
      ..color = const Color(0xFF51565A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, outline);
    canvas.drawRect(
      Rect.fromCenter(center: center.translate(-2.4, 0), width: 1.1, height: 18),
      groove,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center.translate(2.4, 0), width: 1.1, height: 18),
      groove,
    );
  }
}
