import 'package:flutter/material.dart';

class VolumeBar extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onVolumeChanged;

  const VolumeBar({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const dotCount = 13;

    return Positioned(
      right: size.width * 0.018,
      top: size.height * 0.43,
      bottom: size.height * 0.175,
      child: Row(
        children: [
          // Vertical "volume" label
          Opacity(
            opacity: 0.45,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                'v\no\nl\nu\nm\ne',
                style: TextStyle(
                  fontFamily: 'Kallisto',
                  color: Colors.white,
                  fontSize: 14,
                  height: 2.2,
                  letterSpacing: 0.3
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          SizedBox(
            width: size.width * 0.095,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final activeDots = (volume * (dotCount - 1)).round();

                double dyToVolume(double dy) {
                  final v = 1 - (dy / constraints.maxHeight);
                  return v.clamp(0.0, 1.0);
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) {
                    onVolumeChanged(dyToVolume(details.localPosition.dy));
                  },
                  onTapDown: (details) {
                    onVolumeChanged(dyToVolume(details.localPosition.dy));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(dotCount, (i) {
                        final reverseIndex = (dotCount - 1) - i;
                        final isActive = reverseIndex <= activeDots;
                        final t = i / (dotCount - 1);
                        final passiveColor = Color.lerp(
                          const Color(0xFF8FA3B0),
                          const Color(0xFF5E7181),
                          t,
                        )!;
                        final activeColor = Color.lerp(
                          const Color(0xFFFF8A3D),
                          const Color(0xFF00F45E),
                          t,
                        )!;
                        return Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? activeColor : passiveColor.withOpacity(0.45),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: activeColor.withOpacity(0.45),
                                      blurRadius: 8,
                                      spreadRadius: 0.2,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
