import 'package:flutter/material.dart';

class DotVolumeMeter extends StatelessWidget {
  final double value; // 0..1
  final ValueChanged<double> onChanged;
  final double width;
  final double height;
  final int dotCount;

  const DotVolumeMeter({
    super.key,
    required this.value,
    required this.onChanged,
    required this.width,
    required this.height,
    this.dotCount = 14,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    final activeDots = (v * dotCount).round().clamp(0, dotCount);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (d) => _setFromDx(d.localPosition.dx),
      onPanUpdate: (d) => _setFromDx(d.localPosition.dx),
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height),
          color: Colors.black.withOpacity(0.18),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dotCount, (i) {
              final isActive = i < activeDots;

              Color activeColorForIndex(int index) {
                final t = dotCount <= 1 ? 0.0 : index / (dotCount - 1);
                if (t < 0.55) {
                  final u = t / 0.55;
                  return Color.lerp(const Color(0xFF1CFF6A), const Color(0xFFF1FF3A), u)!;
                } else {
                  final u = (t - 0.55) / (1.0 - 0.55);
                  return Color.lerp(const Color(0xFFF1FF3A), const Color(0xFFFF8A1F), u)!;
                }
              }

              final dotColor = isActive
                  ? activeColorForIndex(i)
                  : Colors.white.withOpacity(0.22);

              return Container(
                width: height * 0.23,
                height: height * 0.23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: dotColor.withOpacity(0.35),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                    ),
                  ]
                      : [],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _setFromDx(double dx) {
    final x = dx.clamp(0.0, width);
    final newValue = (x / width).clamp(0.0, 1.0);
    final snapped = (newValue * dotCount).round() / dotCount;
    onChanged(snapped.clamp(0.0, 1.0));
  }
}