import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math' as math;
import '../widgets/home_screen_header.dart';
import '../widgets/track_list_widget.dart';
import '../widgets/timer_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Play state tracking
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isFirstLaunch = true; // All tracks in black on first launch

  // Selected track index
  int _selectedTrackIndex = -1;

  // Timer mode
  bool _isTimerMode = false;
  final Duration _timerDuration = const Duration(hours: 8);
  Duration _remainingTime = const Duration(hours: 8);
  double _fadeOutMinutes = 1.5;
  Timer? _timer;

  // Volume
  double _volume = 0.7; // 70% volume

  // Fade animation controller
  AnimationController? _fadeController;

  // Blink animation for pause state
  AnimationController? _blinkController;
  late Animation<double> _blinkAnimation;

  // Track list
  final List<Map<String, String>> _tracks = [
    {'name': 'ocean aire : calm', 'file': 'audio/TR-OAC.mst13.mp3'},
    {'name': 'ocean aire : active', 'file': 'audio/TR-OAA.mst11.mp3'},
    {'name': 'rain : light', 'file': 'audio/TR-Rain-lite.mst13.mp3'},
    {'name': 'rain : medium', 'file': 'audio/TR-Rain-med.mst13.mp3'},
    {'name': 'storm : light', 'file': 'audio/TR-Storm-lite.mst11.mp3'},
    {'name': 'storm : active', 'file': 'audio/TR-Storm-actv.mst11.mp3'},
    {'name': 'stream : light', 'file': 'audio/TR-Stream.mst11.mp3'},
    {'name': 'stream : medium', 'file': 'audio/TR-River.mst11.mp3'},
    {'name': 'crickets : medium', 'file': 'audio/TR-Crickets.mst11.mp3'},
    {'name': 'winds : medium', 'file': 'audio/TR-Wind.mst14.mp3'},
    {'name': 'white WAV : dynamic', 'file': 'audio/TR-WhiteWAV.mst10.mp3'},
    {'name': 'white noise : static', 'file': 'audio/TR-StandardWNoise.mp3'}
  ];

  @override
  void initState() {
    super.initState();

    // Initialize fade controller for audio fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Initialize blink controller for pause indicator
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController!, curve: Curves.easeInOut),
    );

    // Set to loop
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    // Listen to audio player completion
    _audioPlayer.onPlayerComplete.listen((event) {
      // Audio completed (shouldn't happen with loop, but just in case)
    });
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _blinkController?.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // Play/Pause toggle
  Future<void> _togglePlayPause(int trackIndex) async {
    if (_isPlaying && _selectedTrackIndex == trackIndex) {
      // Pause current track
      await _audioPlayer.pause();
      setState(() {
        _isPaused = true;
        _isPlaying = false;
      });
    } else {
      // Play track (either new track or resume)
      if (_selectedTrackIndex != trackIndex || _isFirstLaunch) {
        // New track selected
        setState(() {
          _selectedTrackIndex = trackIndex;
          _isFirstLaunch = false;
        });

        // For now, use a placeholder audio file
        // In production, load from _tracks[trackIndex]['file']
        await _audioPlayer.stop();

        // Start from random position (no need to start from beginning)
        await _audioPlayer.play(AssetSource(_tracks[trackIndex]['file']!));

        // Fade in over 2 seconds
        await _fadeInAudio();
      } else {
        // Resume paused track
        await _audioPlayer.resume();
        await _fadeInAudio();
      }

      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });

      // Start timer if in timer mode
      if (_isTimerMode) {
        _startTimer();
      }
    }
  }

  // Fade in audio over 2 seconds
  Future<void> _fadeInAudio() async {
    _fadeController?.reset();
    _fadeController?.forward();

    for (int i = 0; i <= 20; i++) {
      double volume = (i / 20) * _volume;
      await _audioPlayer.setVolume(volume);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // Timer functionality
  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = _timerDuration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
      } else {
        // Timer finished
        timer.cancel();
        _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
      }
    });
  }

  // Toggle timer mode
  void _toggleTimerMode() {
    print('DEBUG: Timer clicked! Current mode: $_isTimerMode');
    setState(() {
      _isTimerMode = !_isTimerMode;
      print('DEBUG: Timer mode changed to: $_isTimerMode');
      if (!_isTimerMode) {
        _timer?.cancel();
        _remainingTime = _timerDuration;
      } else if (_isPlaying) {
        _startTimer();
      }
    });
  }

  // Show timer modal
  void _showTimerModal() {
    showDialog(
      context: context,
      builder: (context) => TimerModal(
        initialDuration: _remainingTime,
        initialFadeOutMinutes: _fadeOutMinutes,
        onSave: (duration, fadeOut) {
          setState(() {
            _remainingTime = duration;
            _fadeOutMinutes = fadeOut;
            _isTimerMode = true;
            if (_isPlaying) {
              _startTimer();
            }
          });
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // Change volume
  void _changeVolume(double value) {
    setState(() {
      _volume = value;
    });
    _audioPlayer.setVolume(_volume);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/tinnitus_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [

              // 1️⃣ Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/tinnitus_bg.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 2️⃣ Top decorative vector
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/top_vector.png",
                  height: size.height * 0.18,
                  fit: BoxFit.cover,
                ),
              ),

              // 3️⃣ Background gradients
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.blue.withValues(alpha: 0.15),
                        Colors.blue.withValues(alpha: 0.01),
                        Colors.blue.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
              ),

              // 4️⃣ Main content
              Column(
                children: [
                  SizedBox(height: size.height * 0.005),

                  const HomeScreenHeader(),

                  SizedBox(height: size.height * 0.08),

                  _buildControlButtons(),

                  SizedBox(height: size.height * 0.02),

                  Expanded(
                    child: Expanded(child: _buildTrackList()),
                  ),

                  _buildBottomBar(),
                ],
              ),

              // 5️⃣ Volume bar
              _buildVolumeBar(),

              // 6️⃣ Positioned tagline
              Positioned(
                right: size.width * 0.05,
                top: size.height * 0.10,
                child: Text(
                  'the professional masking solution',
                  style: TextStyle(
                    fontFamily: "Kallisto",
                    fontSize: 12,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    final size = MediaQuery.of(context).size;

    return Padding(
      // padding: EdgeInsets.symmetric(horizontal: size.width * 0.09),
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Continuous button with larger hit area
          InkWell(
            onTap: () {
              print('DEBUG: Continuous button tapped!');
              if (_isTimerMode) _toggleTimerMode();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.015,
              ),
              child: Text(
                'continuous',
                style: TextStyle(
                  fontFamily: "Kallisto",
                  fontWeight: !_isTimerMode ? FontWeight.w900 : FontWeight.w300,
                  fontSize: 13,
                  color: !_isTimerMode ? Colors.lightGreenAccent : Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          SizedBox(width: 2),

          // Timer button with larger hit area
          InkWell(
            onTap: () {
              print('DEBUG: Timer button tapped!');
              _showTimerModal();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.015,
              ),
              child: Text(
                'timer',
                style: TextStyle(
                  fontFamily: "Kallisto",
                  fontSize: 13  ,
                  fontWeight: _isTimerMode ? FontWeight.w900 : FontWeight.w300,
                  letterSpacing: 1.5,
                  color: _isTimerMode ? Colors.lightGreenAccent : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackList() {
    return TrackListWidget(
      tracks: _tracks,
      selectedTrackIndex: _selectedTrackIndex,
      isPlaying: _isPlaying,
      isPaused: _isPaused,
      isFirstLaunch: _isFirstLaunch,
      isTimerMode: _isTimerMode,
      remainingTime: _remainingTime,
      blinkAnimation: _blinkAnimation,
      onTrackTap: _togglePlayPause,
    );
  }

  Widget _buildVolumeBar() {
    final size = MediaQuery.of(context).size;

    return Positioned(
      right: size.width * 0.06,
      top: size.height * 0.2,
      bottom: size.height * 0.15,
      child: SizedBox(
        width: size.width * 0.12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: RotatedBox(
                quarterTurns: -1,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 40,
                    thumbShape: SliderComponentShape.noThumb,
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                  ),
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: _changeVolume,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final size = MediaQuery.of(context).size;

    return Container(
      // Add background color here
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1), // Semi-transparent black
        borderRadius: BorderRadius.circular(2), // Optional: rounded corners
      ),

      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
        vertical: size.height * 0.018,
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left block: label + dot meter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "volume",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: size.width * 0.032,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: size.height * 0.008),
                _DotVolumeMeter(
                  value: _volume, // 0.0 -> 1.0
                  onChanged: _changeVolume,
                  width: size.width * 0.62,
                  height: size.height * 0.055,
                  dotCount: 14,
                ),
              ],
            ),
          ),

          SizedBox(width: size.width * 0.04),

          // Gear icon (right)
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings clicked')),
              );
            },
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

class _DotVolumeMeter extends StatelessWidget {
  final double value; // 0..1
  final ValueChanged<double> onChanged;
  final double width;
  final double height;
  final int dotCount;

  const _DotVolumeMeter({
    required this.value,
    required this.onChanged,
    required this.width,
    required this.height,
    this.dotCount = 14,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    final activeDots = (v * dotCount).round().clamp(0, dotCount);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (d) => _setFromDx(d.localPosition.dx),
      onPanUpdate: (d) => _setFromDx(d.localPosition.dx),
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height),
          // capsule background like screenshot (dark translucent)
          color: Colors.black.withOpacity(0.18),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dotCount, (i) {
              final isActive = i < activeDots;

              // Gradient across active dots: green -> yellow -> orange
              Color activeColorForIndex(int index) {
                final t = dotCount <= 1 ? 0.0 : index / (dotCount - 1);
                // piecewise gradient
                if (t < 0.55) {
                  // green -> yellow
                  final u = t / 0.55;
                  return Color.lerp(const Color(0xFF1CFF6A), const Color(0xFFF1FF3A), u)!;
                } else {
                  // yellow -> orange
                  final u = (t - 0.55) / (1.0 - 0.55);
                  return Color.lerp(const Color(0xFFF1FF3A), const Color(0xFFFF8A1F), u)!;
                }
              }

              final dotColor = isActive
                  ? activeColorForIndex(i)
                  : Colors.white.withOpacity(0.22);

              return Container(
                width: height * 0.23,
                height: height * 0.23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: dotColor.withOpacity(0.35),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                    ),
                  ]
                      : [],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _setFromDx(double dx) {
    // convert tap/drag X to 0..1
    final x = dx.clamp(0.0, width);
    final newValue = (x / width).clamp(0.0, 1.0);
    // snap to dot steps (like screenshot)
    final snapped = (newValue * dotCount).round() / dotCount;
    onChanged(snapped.clamp(0.0, 1.0));
  }
}







