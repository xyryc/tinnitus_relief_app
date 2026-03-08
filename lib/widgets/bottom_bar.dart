import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final bool isPlaying;
  final Duration duration;
  final VoidCallback onPrimaryTap;
  final ValueChanged<double> onDurationChanged;
  final VoidCallback onSettingsTap;

  const BottomBar({
    super.key,
    required this.isPlaying,
    required this.duration,
    required this.onPrimaryTap,
    required this.onDurationChanged,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sliderValue = duration.inHours.clamp(1, 10).toDouble();
    final timerText = '${duration.inHours}:00';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF08395A).withOpacity(0.52),
            const Color(0xFF07253D).withOpacity(0.68),
          ],
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.04), width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        size.width * 0.055,
        size.height * 0.008,
        size.width * 0.04,
        size.height * 0.012,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onPrimaryTap,
            child: SizedBox(
              width: size.width * 0.13,
              height: size.width * 0.13,
              child: CustomPaint(
                painter: _PlayButtonPainter(isPlaying: isPlaying),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timerText,
                  style: TextStyle(
                    fontFamily: 'Kallisto',
                    fontSize: size.width * 0.042,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF17FF2E),
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF17FF2E).withOpacity(0.35),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.002),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(10, (index) {
                    final number = index + 1;
                    final isSelected = number == sliderValue.round();
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.006),
                      child: Text(
                        '$number',
                        style: TextStyle(
                          fontFamily: 'Kallisto',
                          fontSize: size.width * 0.017,
                          color: isSelected
                              ? const Color(0xFF8CFF31)
                              : Colors.white.withOpacity(0.48),
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: size.height * 0.001),
                SizedBox(
                  height: size.height * 0.036,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 7,
                        margin: EdgeInsets.symmetric(horizontal: size.width * 0.09),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF7B7761),
                              const Color(0xFF373A31),
                              const Color(0xFF78735F),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.45),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.16),
                          ),
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 8,
                          activeTrackColor: Colors.transparent,
                          inactiveTrackColor: Colors.transparent,
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbShape: const _MetalThumbShape(),
                        ),
                        child: Slider(
                          value: sliderValue,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          padding: EdgeInsets.symmetric(horizontal: size.width * 0.09),
                          onChanged: onDurationChanged,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -3),
                  child: Text(
                    'duration',
                    style: TextStyle(
                      fontFamily: 'Kallisto',
                      fontSize: size.width * 0.022,
                      color: Colors.white.withOpacity(0.38),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: size.width * 0.025),
          GestureDetector(
            onTap: onSettingsTap,
            child: Image.asset(
              'assets/images/settings.png',
              width: size.width * 0.075,
              height: size.width * 0.075,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayButtonPainter extends CustomPainter {
  final bool isPlaying;

  const _PlayButtonPainter({required this.isPlaying});

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
  bool shouldRepaint(covariant _PlayButtonPainter oldDelegate) {
    return oldDelegate.isPlaying != isPlaying;
  }
}

class _MetalThumbShape extends SliderComponentShape {
  const _MetalThumbShape();

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
    final groove = Paint()
      ..color = const Color(0xFF7E8388);
    final outline = Paint()
      ..color = const Color(0xFF51565A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, outline);
    canvas.drawRect(Rect.fromCenter(center: center.translate(-2.4, 0), width: 1.1, height: 18), groove);
    canvas.drawRect(Rect.fromCenter(center: center.translate(2.4, 0), width: 1.1, height: 18), groove);
  }
}
