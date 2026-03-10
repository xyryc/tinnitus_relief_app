import 'package:flutter/material.dart';
import 'bottom_bar_painters.dart';

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
    final isInfinite = duration == Duration.zero;
    final sliderValue = isInfinite ? 11.0 : duration.inHours.clamp(1, 10).toDouble();
    final timerText = isInfinite ? '∞' : '${duration.inHours}:00';

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
              width: 40,
              height: 40,
              child: CustomPaint(
                painter: PlayButtonPainter(isPlaying: isPlaying),
              ),
            ),
          ),

          SizedBox(width: 2),

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
                  children: List.generate(11, (index) {
                    final isLast = index == 10;
                    final number = index + 1;
                    final isSelected = number == sliderValue.round();
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: isLast
                          ? Icon(
                              Icons.all_inclusive,
                              size: 18,
                              color: isSelected
                                  ? const Color(0xFF00FF5A)
                                  : Colors.white.withOpacity(0.48),
                            )
                          : Text(
                              '$number',
                              style: TextStyle(
                                fontFamily: 'Kallisto',
                                fontSize: 14,
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
                          thumbShape: const MetalThumbShape(),
                        ),
                        child: Slider(
                          value: sliderValue,
                          min: 1,
                          max: 11,
                          divisions: 10,
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

          SizedBox(width: 2),

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
