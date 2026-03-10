import 'package:flutter/material.dart';

class ListScrollControl extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool flipIcon;
  final VoidCallback onTap;

  const ListScrollControl({
    super.key,
    required this.label,
    required this.icon,
    this.flipIcon = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const markerColor = Color(0xFFC7F535);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Transform.rotate(
            angle: flipIcon ? 3.14159 : 0,
            child: Icon(icon, color: markerColor, size: 16),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Kallisto',
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
