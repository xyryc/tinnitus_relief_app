import 'package:flutter/material.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.start,
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Kallisto',
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'tinnitus',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'relief',
                style: TextStyle(color: Color(0xFF64B5F6)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'professional masking solution',
          style: TextStyle(
            fontFamily: 'Kallisto',
            fontSize: 14,
            color: Colors.white70,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'earvana.org',
          style: TextStyle(
            fontFamily: 'Kallisto',
            fontSize: 12,
            color: Color(0xFF64B5F6),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
