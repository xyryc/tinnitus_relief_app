import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class Buildheader extends StatelessWidget {
  const Buildheader({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      "tinnitus",
                      style: TextStyle(
                        fontFamily: "Kallisto",
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      "relief",
                      style: TextStyle(
                        fontFamily: "Kallisto",
                        fontWeight: FontWeight.w100,
                        fontSize: 30,
                        color: Color(0xFF1336e8),
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Text(
                  'professional masking solution',
                  style: const TextStyle(
                    fontFamily: "Kallisto",
                    fontWeight: FontWeight.w300,
                    fontSize: 11,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black45,
                      ),
                    ],
                  )
                ),
              ],
            ),
          ],
        ),
      );
  }
}
