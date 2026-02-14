import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';

class TimerModal extends StatefulWidget {
  final Duration initialDuration;
  final double initialFadeOutMinutes;
  final Function(Duration, double) onSave;
  final VoidCallback onClose;

  const TimerModal({
    super.key,
    required this.initialDuration,
    required this.initialFadeOutMinutes,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<TimerModal> createState() => _TimerModalState();
}

class _TimerModalState extends State<TimerModal> {
  late int _selectedHours;
  late int _selectedMinutes;
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;

  bool _isAM = true;
  DateTime _currentTime = DateTime.now();
  Timer? _clockTimer;

  DateTime? _stopTime;
  late double _fadeOutMinutes;

  @override
  void initState() {
    super.initState();

    // Initialize duration
    _selectedHours = widget.initialDuration.inHours;
    _selectedMinutes = widget.initialDuration.inMinutes.remainder(60);
    _fadeOutMinutes = widget.initialFadeOutMinutes;

    // Initialize scroll controllers
    _hoursController = FixedExtentScrollController(
      initialItem: _selectedHours,
    );
    _minutesController = FixedExtentScrollController(
      initialItem: _selectedMinutes ~/ 15,
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
      // Update duration based on stop time
      final newDuration = _stopTime!.difference(_currentTime);
      _selectedHours = newDuration.inHours;
      _selectedMinutes = newDuration.inMinutes.remainder(60);
    });
  }

  void _decrementStopTime() {
    setState(() {
      _stopTime = _stopTime?.subtract(const Duration(minutes: 15));
      // Update duration based on stop time
      final newDuration = _stopTime!.difference(_currentTime);
      _selectedHours = newDuration.inHours;
      _selectedMinutes = newDuration.inMinutes.remainder(60);
    });
  }

  void _handleSave() {
    final duration = Duration(hours: _selectedHours, minutes: _selectedMinutes);
    widget.onSave(duration, _fadeOutMinutes);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return SafeArea(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
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
                    constraints: BoxConstraints(
                      maxHeight: size.height * 0.85,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              'TIMER',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 4,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Current Time Section
                            _buildCurrentTimeSection(),

                            const SizedBox(height: 20),

                            // Duration Picker Section
                            _buildDurationSection(),

                            const SizedBox(height: 20),

                            // Stop Time Section
                            _buildStopTimeSection(),

                            const SizedBox(height: 20),

                            // Fade Out Section
                            _buildFadeOutSection(),

                            const SizedBox(height: 20),

                            // Save Button
                            ElevatedButton(
                              onPressed: _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF64B5F6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                shadowColor: const Color(0xFF64B5F6).withOpacity(0.5),
                              ),
                              child: const Text(
                                'SAVE',
                                style: TextStyle(
                                  fontFamily: 'Kallisto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              left: size.width * 0.12,
              top: size.height * 0.10,
              child: GestureDetector(
                onTap: widget.onClose,
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

  Widget _buildCurrentTimeSection() {
    return Column(
      children: [
        Text(
          'current time',
          style: TextStyle(
            fontFamily: 'Kallisto',
            fontSize: 14,
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
                style: TextStyle(
                  fontFamily: 'Kallisto',
                  fontSize: 12,
                  color: _isAM ? Colors.white : Colors.white38,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 80),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isAM = false;
                });
              },
              child: Text(
                'PM',
                style: TextStyle(
                  fontFamily: 'Kallisto',
                  fontSize: 12,
                  color: !_isAM ? const Color(0xFF7FFF00) : Colors.white38,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Analog Clock
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
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
          style: TextStyle(
            fontFamily: 'Kallisto',
            fontSize: 14,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),

        // Hour and Minute Pickers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hours
            Column(
              children: [
                Text(
                  'hrs',
                  style: TextStyle(
                    fontFamily: 'Kallisto',
                    fontSize: 11,
                    color: Colors.white54,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                _buildNumberPicker(
                  controller: _hoursController,
                  maxValue: 23,
                  onChanged: (value) {
                    setState(() {
                      _selectedHours = value;
                      _calculateStopTime();
                    });
                  },
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Colon separator
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                ':',
                style: TextStyle(
                  fontFamily: 'Kallisto',
                  fontSize: 28,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Minutes
            Column(
              children: [
                Text(
                  'mins',
                  style: TextStyle(
                    fontFamily: 'Kallisto',
                    fontSize: 11,
                    color: Colors.white54,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                _buildNumberPicker(
                  controller: _minutesController,
                  maxValue: 45,
                  interval: 15,
                  onChanged: (value) {
                    setState(() {
                      _selectedMinutes = value;
                      _calculateStopTime();
                    });
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
    required FixedExtentScrollController controller,
    required int maxValue,
    int interval = 1,
    required Function(int) onChanged,
  }) {
    return Container(
      height: 150,
      width: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
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
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF7FFF00).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          // Scrollable numbers
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 50,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              onChanged(index * interval);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index > maxValue ~/ interval) return null;

                final value = index * interval;
                final isSelected = controller.hasClients && 
                    controller.selectedItem == index;

                return Center(
                  child: Text(
                    value.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontFamily: 'Kallisto',
                      fontSize: isSelected ? 28 : 20,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                );
              },
              childCount: (maxValue ~/ interval) + 1,
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
          style: TextStyle(
            fontFamily: 'Kallisto',
            fontSize: 14,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),

        // Stop time clock with +/- buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minus button
            IconButton(
              onPressed: _decrementStopTime,
              icon: const Icon(Icons.remove, color: Colors.white70, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),

            const SizedBox(width: 8),

            // Clock
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: ClockPainter(time: _stopTime ?? DateTime.now()),
              ),
            ),

            const SizedBox(width: 8),

            // Plus button
            IconButton(
              onPressed: _incrementStopTime,
              icon: const Icon(Icons.add, color: Colors.white70, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
          style: TextStyle(
            fontFamily: 'Kallisto',
            fontSize: 14,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),

        // Minutes display
        Text(
          '${_fadeOutMinutes.toStringAsFixed(1)} min',
          style: TextStyle(
            fontFamily: 'Kallisto',
            fontSize: 16,
            color: const Color(0xFFFFD700),
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
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
      final x = center.dx + (radius - 15) * _cos(angle);
      final y = center.dy + (radius - 15) * _sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: i.toString(),
          style: const TextStyle(
            fontFamily: 'Kallisto',
            color: Colors.black,
            fontSize: 11,
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
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius * 0.4) * _cos(hourAngle),
        center.dy + (radius * 0.4) * _sin(hourAngle),
      ),
      hourPaint,
    );

    // Draw minute hand
    final minuteAngle = (time.minute * 6 - 90) * (3.14159 / 180);
    final minutePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius * 0.6) * _cos(minuteAngle),
        center.dy + (radius * 0.6) * _sin(minuteAngle),
      ),
      minutePaint,
    );

    // Draw center dot
    final centerDotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerDotPaint);
  }

  // Helper functions for cos/sin
  double _cos(double radians) {
    double x = radians;
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _sin(double radians) {
    double x = radians;
    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

// Chamfer clipper for cut corners (matching settings modal)
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

// Helper function
double mathMin(double a, double b) => a < b ? a : b;
