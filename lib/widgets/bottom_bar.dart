import 'package:flutter/material.dart';
import 'dot_volume_meter.dart';

class BottomBar extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onSettingsTap;

  const BottomBar({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
        vertical: size.height * 0.018,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left block: label + dot meter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "volume",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: size.width * 0.032,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: size.height * 0.008),
                DotVolumeMeter(
                  value: volume,
                  onChanged: onVolumeChanged,
                  width: size.width * 0.62,
                  height: size.height * 0.055,
                  dotCount: 14,
                ),
              ],
            ),
          ),

          SizedBox(width: size.width * 0.04),

          // Gear icon (right)
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