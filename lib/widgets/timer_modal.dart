import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class TimerModal extends StatefulWidget {
  final Duration initialDuration;
  final Function(Duration) onDurationChanged;
  final VoidCallback onClose;

  const TimerModal({
    super.key,
    required this.initialDuration,
    required this.onDurationChanged,
    required this.onClose,
  });

  @override
  State<TimerModal> createState() => _TimerModalState();
}

class _TimerModalState extends State<TimerModal> {
  late int _selectedHours;
  late int _selectedMinutes;
  late ScrollController _hoursController;
  late ScrollController _minutesController;

  bool _isAM = true;
  DateTime _currentTime = DateTime.now();
  Timer? _clockTimer;

  DateTime? _stopTime;
  double _fadeOutMinutes = 1.5;

  @override
  void initState() {
    super.initState();

    // Initialize duration
    _selectedHours = widget.initialDuration.inHours;
    _selectedMinutes = widget.initialDuration.inMinutes.remainder(60);

    // Initialize scroll controllers
    _hoursController = ScrollController(
      initialScrollOffset: _selectedHours * 60.0,
    );
    _minutesController = ScrollController(
      initialScrollOffset: _selectedMinutes * 60.0,
    );

    // Update current time every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    // Calculate stop time
    _calculateStopTime();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _calculateStopTime() {
    final duration = Duration(hours: _selectedHours, minutes: _selectedMinutes);
    setState(() {
      _stopTime = _currentTime.add(duration);
    });
  }

  void _incrementStopTime() {
    setState(() {
      _stopTime = _stopTime?.add(const Duration(minutes: 15));
    });
  }

  void _decrementStopTime() {
    setState(() {
      _stopTime = _stopTime?.subtract(const Duration(minutes: 15));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2d5f7f).withOpacity(0.95),
              const Color(0xFF1a4a6f).withOpacity(0.95),
              const Color(0xFF2d5f7f).withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF64B5F6).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'TIMER',
                    style: GoogleFonts.orbitron(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 8,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Current Time Section
                  _buildCurrentTimeSection(),

                  const SizedBox(height: 30),

                  // Duration Picker Section
                  _buildDurationSection(),

                  const SizedBox(height: 30),

                  // Stop Time Section
                  _buildStopTimeSection(),

                  const SizedBox(height: 30),

                  // Fade Out Section
                  _buildFadeOutSection(),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Close button
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTimeSection() {
    return Column(
      children: [
        Text(
          'current time',
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),

        // AM/PM Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isAM = true;
                });
              },
              child: Text(
                'AM',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: _isAM ? Colors.white : Colors.white38,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 100),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isAM = false;
                });
              },
              child: Text(
                'PM',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: !_isAM ? const Color(0xFF7FFF00) : Colors.white38,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Analog Clock
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomPaint(
            painter: ClockPainter(time: _currentTime),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      children: [
        Text(
          'duration',
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),

        // Hour and Minute Pickers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hours
            Column(
              children: [
                Text(
                  'hrs',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white54,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                _buildNumberPicker(
                  controller: _hoursController,
                  maxValue: 23,
                  onChanged: (value) {
                    setState(() {
                      _selectedHours = value;
                      _calculateStopTime();
                    });
                    widget.onDurationChanged(
                      Duration(hours: _selectedHours, minutes: _selectedMinutes),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Colon separator
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                ':',
                style: GoogleFonts.roboto(
                  fontSize: 32,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Minutes
            Column(
              children: [
                Text(
                  'mins',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white54,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                _buildNumberPicker(
                  controller: _minutesController,
                  maxValue: 59,
                  interval: 15,
                  onChanged: (value) {
                    setState(() {
                      _selectedMinutes = value;
                      _calculateStopTime();
                    });
                    widget.onDurationChanged(
                      Duration(hours: _selectedHours, minutes: _selectedMinutes),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberPicker({
    required ScrollController controller,
    required int maxValue,
    int interval = 1,
    required Function(int) onChanged,
  }) {
    return Container(
      height: 180,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Selection highlight
          Center(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF64B5F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Scrollable numbers
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final offset = controller.offset;
                final index = (offset / 60).round();
                final targetOffset = index * 60.0;
                controller.animateTo(
                  targetOffset,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
                onChanged(index * interval);
              }
              return true;
            },
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: 60,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index < 0 || index > maxValue ~/ interval) return null;

                  final value = index * interval;
                  final scrollOffset = controller.hasClients ? controller.offset : 0;
                  final itemOffset = (index * 60.0 - scrollOffset).abs();
                  final isCenter = itemOffset < 30;

                  return Center(
                    child: Text(
                      value.toString().padLeft(2, '0'),
                      style: GoogleFonts.roboto(
                        fontSize: isCenter ? 32 : 24,
                        fontWeight: isCenter ? FontWeight.w500 : FontWeight.w300,
                        color: isCenter
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  );
                },
                childCount: (maxValue ~/ interval) + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopTimeSection() {
    return Column(
      children: [
        Text(
          'stop time',
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),

        // AM/PM for stop time
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _stopTime != null && _stopTime!.hour < 12 ? 'AM' : 'AM',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.white38,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 100),
            Text(
              'PM',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: const Color(0xFF7FFF00),
                letterSpacing: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Stop time clock with +/- buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minus button
            IconButton(
              onPressed: _decrementStopTime,
              icon: const Icon(Icons.remove, color: Colors.white70, size: 24),
            ),

            const SizedBox(width: 16),

            // Clock
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: ClockPainter(time: _stopTime ?? DateTime.now()),
              ),
            ),

            const SizedBox(width: 16),

            // Plus button
            IconButton(
              onPressed: _incrementStopTime,
              icon: const Icon(Icons.add, color: Colors.white70, size: 24),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFadeOutSection() {
    return Column(
      children: [
        Text(
          'fade out',
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),

        // Fade out slider
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dot indicators
            ...List.generate(20, (index) {
              final isActive = index < (_fadeOutMinutes * 10).round();
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFFFD700)
                      : Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              );
            }),

            const SizedBox(width: 12),

            // Minutes display
            Text(
              '${_fadeOutMinutes.toStringAsFixed(1)} min',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: const Color(0xFFFFD700),
                letterSpacing: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Slider
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: const Color(0xFFFFD700),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            thumbColor: const Color(0xFFFFD700),
          ),
          child: Slider(
            value: _fadeOutMinutes,
            min: 0.0,
            max: 10.0,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                _fadeOutMinutes = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

// Custom painter for analog clock
class ClockPainter extends CustomPainter {
  final DateTime time;

  ClockPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw clock face
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 1, borderPaint);

    // Draw hour markers
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * (3.14159 / 180);
      final x = center.dx + (radius - 20) * cos(angle);
      final y = center.dy + (radius - 20) * sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: i.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw hour hand
    final hourAngle = ((time.hour % 12) * 30 + time.minute * 0.5 - 90) * (3.14159 / 180);
    final hourPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius * 0.4) * cos(hourAngle),
        center.dy + (radius * 0.4) * sin(hourAngle),
      ),
      hourPaint,
    );

    // Draw minute hand
    final minuteAngle = (time.minute * 6 - 90) * (3.14159 / 180);
    final minutePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius * 0.6) * cos(minuteAngle),
        center.dy + (radius * 0.6) * sin(minuteAngle),
      ),
      minutePaint,
    );

    // Draw center dot
    final centerDotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, centerDotPaint);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

// Helper function to use cosine (dart:math)
double cos(double radians) {
  return radians.cos();
}

double sin(double radians) {
  return radians.sin();
}

extension on double {
  double cos() {
    double x = this;
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double sin() {
    double x = this;
    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}