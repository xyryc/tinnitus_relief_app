import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

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
  final Duration _timerDuration = const Duration(hours: 7);
  Duration _remainingTime = const Duration(hours: 7);
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
    {'name': 'ocean aire : calm', 'file': 'assets/audio/ocean_calm.mp3'},
    {'name': 'ocean aire : breezy', 'file': 'assets/audio/ocean_breezy.mp3'},
    {'name': 'ocean aire : active', 'file': 'assets/audio/ocean_active.mp3'},
    {'name': 'winds : calm', 'file': 'assets/audio/winds_calm.mp3'},
    {'name': 'winds : active', 'file': 'assets/audio/winds_active.mp3'},
    {'name': 'rain : light', 'file': 'assets/audio/rain_light.mp3'},
    {'name': 'rain : medium', 'file': 'assets/audio/rain_medium.mp3'},
    {'name': 'storm : light', 'file': 'assets/audio/storm_light.mp3'},
    {'name': 'storm : active', 'file': 'assets/audio/storm_active.mp3'},
    {'name': 'stream : light', 'file': 'assets/audio/stream_light.mp3'},
    {'name': 'stream : medium', 'file': 'assets/audio/stream_medium.mp3'},
    {'name': 'white noise : static', 'file': 'assets/audio/white_noise_static.mp3'},
    {'name': 'white WAV : dynamic', 'file': 'assets/audio/white_wav_dynamic.mp3'},
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
        await _audioPlayer.play(AssetSource('audio/sample.mp3'));

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
          decoration: BoxDecoration(
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

              // 3️⃣ Background gradients (BEHIND content)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.blue.withValues(alpha: 0.50),
                        Colors.blue.withValues(alpha: 0.25),
                        Colors.blue.withValues(alpha: 0.50),
                      ],
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  SizedBox(height: size.height * 0.005),

                  HomeScreenHeader(),

                  SizedBox(height: size.height * 0.06),

                  _buildControlButtons(),

                  SizedBox(height: size.height * 0.02),

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildTrackList()),
                      ],
                    ),
                  ),

                  _buildSettingsButton(),

                  SizedBox(height: size.height * 0.025),
                ],
              ),

              _buildVolumeBar(),

              Positioned(
                right: size.width * 0.05,
                top: size.height * 0.10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'earvana.',
                      style: TextStyle(
                        fontFamily: "Kallisto",
                        fontSize: size.width * 0.045,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'org',
                      style: TextStyle(
                        fontFamily: "Kallisto",
                        fontWeight: FontWeight.w200,
                        fontSize: size.width * 0.032,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ],
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
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.09),
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
                  fontSize: size.width * 0.037,
                  color: !_isTimerMode ? Colors.lightGreenAccent : Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          SizedBox(width: size.width * 0.05),

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
                  fontSize: size.width * 0.037,
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

  Widget _buildSettingsButton() {
    final size = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(right: size.width * 0.06),
        child: IconButton(
          icon: Icon(
            Icons.settings,
            color: const Color(0xFF54999d),
            size: size.width * 0.075,
          ),
          onPressed: () {
            // Settings action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings clicked')),
            );
          },
        ),
      ),
    );
  }
}







