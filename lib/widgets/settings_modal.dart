import 'dart:ui';
import 'package:flutter/material.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // Center glass panel
            Center(
              child: ClipPath(
                clipper: _ChamferClipper(
                  topLeft: 18,
                  topRight: 32,
                  bottomLeft: 32,
                  bottomRight: 18,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: mathMin(size.width * 0.88, 600),
                    height: mathMin(size.height * 0.72, 720),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1d24).withOpacity(0.70),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 14),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // Title area
                        Padding(
                          padding: const EdgeInsets.only(top: 18, bottom: 10),
                          child: Text(
                            "SETTINGS",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 34,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // subtle separator line
                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.08),
                        ),

                        // Scroll content
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(bottom: 18),
                            children: const [
                              SizedBox(height: 10),

                              _SectionHeader("audio output"),
                              _SectionBody(
                                "!!!   NOTE:  The user should be able to switch between:\n"
                                    ">  internal speaker\n"
                                    ">  bluetooth device (s)\n"
                                    ">  misc, etc",
                              ),

                              _SectionHeader("my subscription"),
                              _SectionBody(
                                "!!!   NOTE:\n"
                                    "do we need anything here?     if there’s only 1 subscription option, maybe not?",
                              ),

                              _SectionHeader("leave a review"),
                              _SectionBody(
                                "!!!   NOTE:\n"
                                    "this would link to OUR review page in the App Store/Google Play Store",
                              ),

                              _SectionHeader("faq"),
                              _SectionBody(
                                "!!!   note:  we can either invoke a new popup window here - with text…\n"
                                    "or…   just link to the website FAQ page?",
                              ),

                              _SectionHeader("legal"),
                              _LegalLinks(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Close X (top-left of panel area)
            Positioned(
              left: size.width * 0.12,
              top: size.height * 0.10,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.close,
                  size: 34,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header bar (cyan text on darker strip)
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      color: Colors.blue.withOpacity(0.08), // subtle section background
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2FD6EA),
          fontSize: 26,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

/// Section body text block
class _SectionBody extends StatelessWidget {
  final String text;
  const _SectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.82),
          fontSize: 15,
          height: 1.35,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Legal links block (matches screenshot layout)
class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    Widget link(String label, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 22,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "»",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          link("privacy policy", () {}),
          link("terms and conditions", () {}),
        ],
      ),
    );
  }
}

/// Chamfer (cut) corners clipper to match the angled corners in the design.
class _ChamferClipper extends CustomClipper<Path> {
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  _ChamferClipper({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  @override
  Path getClip(Size s) {
    final p = Path();

    // Start top-left with chamfer
    p.moveTo(topLeft, 0);
    p.lineTo(s.width - topRight, 0);
    p.lineTo(s.width, topRight);

    p.lineTo(s.width, s.height - bottomRight);
    p.lineTo(s.width - bottomRight, s.height);

    p.lineTo(bottomLeft, s.height);
    p.lineTo(0, s.height - bottomLeft);

    p.lineTo(0, topLeft);
    p.close();

    return p;
  }

  @override
  bool shouldReclip(covariant _ChamferClipper oldClipper) {
    return topLeft != oldClipper.topLeft ||
        topRight != oldClipper.topRight ||
        bottomLeft != oldClipper.bottomLeft ||
        bottomRight != oldClipper.bottomRight;
  }
}

// tiny helper (avoid importing dart:math in your file if you don’t want to)
double mathMin(double a, double b) => a < b ? a : b;
