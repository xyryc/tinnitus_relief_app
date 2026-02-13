import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final bool isTimerMode;
  final VoidCallback onContinuousTap;
  final VoidCallback onTimerTap;

  const ControlButtons({
    super.key,
    required this.isTimerMode,
    required this.onContinuousTap,
    required this.onTimerTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Continuous button
          InkWell(
            onTap: onContinuousTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.015,
              ),
              child: Text(
                'continuous',
                style: TextStyle(
                  fontFamily: "Kallisto",
                  fontWeight: !isTimerMode ? FontWeight.w900 : FontWeight.w300,
                  fontSize: 13,
                  color: !isTimerMode ? Colors.lightGreenAccent : Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(width: 2),

          // Timer button
          InkWell(
            onTap: onTimerTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.015,
              ),
              child: Text(
                'timer',
                style: TextStyle(
                  fontFamily: "Kallisto",
                  fontSize: 13,
                  fontWeight: isTimerMode ? FontWeight.w900 : FontWeight.w300,
                  letterSpacing: 1.5,
                  color: isTimerMode ? Colors.lightGreenAccent : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}