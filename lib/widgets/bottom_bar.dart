import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const BottomBar({
    super.key,
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
