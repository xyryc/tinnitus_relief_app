import 'package:flutter/material.dart';

class HomeScreenHeader extends StatelessWidget {
  const HomeScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scaleX: 1.25,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: const [
                Text(
                  'tinnitus',
                  style: TextStyle(
                    fontFamily: 'Kallisto',
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.white,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 10,
                        color: Colors.black54,
                      ),
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 18,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'relief',
                  style: TextStyle(
                    fontFamily: 'Kallisto',
                    fontWeight: FontWeight.w400,
                    fontSize: 30,
                    color: Color(0xFF1336e8),
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 10,
                        color: Colors.black54,
                      ),
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 18,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 2),
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'by',
                    style: TextStyle(
                      fontFamily: 'Kallisto',
                      fontWeight: FontWeight.w300,
                      fontSize: 10,
                      color: Colors.white,
                      letterSpacing: 1,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 8,
                          color: Colors.black45,
                        ),
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 14,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Transform.translate(
                    offset: const Offset(0, -2),
                    child: Text(
                      'earvana',
                      style: TextStyle(
                        fontFamily: 'Kallisto',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 1,
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 8,
                            color: Colors.black45,
                          ),
                          Shadow(
                            offset: Offset(0, 0),
                            blurRadius: 14,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'the professional masking solution',
                style: TextStyle(
                  fontFamily: 'Kallisto',
                  fontSize: 12,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  shadows: const [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 8,
                      color: Colors.black45,
                    ),
                    Shadow(
                      offset: Offset(0, 0),
                      blurRadius: 14,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
