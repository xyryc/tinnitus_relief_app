import 'package:flutter/material.dart';

class HomeScreenHeader extends StatelessWidget {
  const HomeScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scaleX: 1.25, // 👈 adjust (1.1 - 1.25 looks good)
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      "tinnitus",
                      style: TextStyle(
                        fontFamily: "Kallisto",
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Colors.white,
                        letterSpacing: 1,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
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
                        fontWeight: FontWeight.w400,
                        fontSize: 30,
                        color: Color(0xFF1336e8),
                        letterSpacing: 1,
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
              ),

              // const SizedBox(height: 4),

             Row(
                 spacing: 3,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                 Text(
                   'by',
                   style: TextStyle(
                     fontFamily: "Kallisto",
                     fontWeight: FontWeight.w300,
                     fontSize: 10,
                     color: Colors.white,
                     letterSpacing: 1,
                     shadows: [
                       Shadow(
                         offset: Offset(0, 1),
                         blurRadius: 2,
                         color: Colors.black45,
                       ),
                     ],
                   ),
                 ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'earvana',
                        style: TextStyle(
                          fontFamily: "Kallisto",
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.white,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),

                      Text(
                        '.org',
                        style: TextStyle(
                          fontFamily: "Kallisto",
                          fontWeight: FontWeight.w300,
                          fontSize: 10,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      )
                    ],
                  )
               ]
             )
            ],
          ),
        ],
      ),
    );
  }
}
