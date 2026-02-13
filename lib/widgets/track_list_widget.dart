import 'package:flutter/material.dart';

class TrackListWidget extends StatelessWidget {
  final List<Map<String, String>> tracks;
  final int selectedTrackIndex;
  final bool isPlaying;
  final bool isPaused;
  final bool isFirstLaunch;
  final bool isTimerMode;
  final Duration remainingTime;
  final Animation<double> blinkAnimation;
  final Function(int) onTrackTap;

  const TrackListWidget({
    super.key,
    required this.tracks,
    required this.selectedTrackIndex,
    required this.isPlaying,
    required this.isPaused,
    required this.isFirstLaunch,
    required this.isTimerMode,
    required this.remainingTime,
    required this.blinkAnimation,
    required this.onTrackTap,
  });

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '$hours:${twoDigits(minutes)}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // padding: const EdgeInsets.only(left: 18, right: 18),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        bool isSelected = selectedTrackIndex == index;
        bool showAsPlaying = isSelected && isPlaying;
        bool showAsPaused = isSelected && isPaused;

        // Color logic
        Color textColor;
        Color iconColor;

        if (isFirstLaunch) {
          // All black on first launch
          textColor = Colors.black;
          iconColor = Colors.black54;
        } else if (showAsPlaying) {
          // Green when playing
          textColor = const Color(0xFF7FFF00);
          iconColor = const Color(0xFF7FFF00);
        } else if (showAsPaused) {
          // Yellow when paused (with blink)
          textColor = const Color(0xFFFFD700);
          iconColor = const Color(0xFFFFD700);
        } else {
          // Gray for unselected
          textColor = Colors.black;
          iconColor = Colors.white54;
        }

        return GestureDetector(
          onTap: () => onTrackTap(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                // Play icon
                showAsPaused
                    ? AnimatedBuilder(
                  animation: blinkAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: blinkAnimation.value,
                      child: Icon(
                        Icons.play_arrow,
                        color: iconColor,
                        size: 24,
                      ),
                    );
                  },
                )
                    : Icon(
                  Icons.play_arrow,
                  color: iconColor,
                  size: 24,
                ),

                const SizedBox(width: 16),

                // Track name
                Expanded(
                  child: Text(
                    tracks[index]['name']!,
                    style: TextStyle(
                      fontFamily: "Kallisto",
                      fontSize: 18,
                      color: textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // Loop icon and timer (only for selected track)
                if (isSelected && isPlaying) ...[ 
                  Icon(
                    Icons.loop,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  if (isTimerMode)
                    Text(
                      _formatDuration(remainingTime),
                      style: TextStyle(
                        fontFamily: "Kallisto",
                        fontSize: 18,
                        color: const Color(0xFF7FFF00),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
