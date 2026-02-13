import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../widgets/home_screen_header.dart';
import '../widgets/track_list_widget.dart';
import '../widgets/timer_modal.dart';
import '../widgets/control_buttons.dart';
import '../widgets/volume_bar.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/settings_modal.dart';


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
  // Show settings modal
  void _openSettingsModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Settings",
      barrierColor: Colors.black.withOpacity(0.35),
      pageBuilder: (_, __, ___) {
        return const SettingsModal();
      },
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

              // 1?? Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/tinnitus_bg.png',
                  fit: BoxFit.cover,
                ),
              ),

              // 2?? Top decorative vector
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

              // 3?? Background gradients
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

              // 4?? Main content
              Column(
                children: [
                  SizedBox(height: size.height * 0.005),

                  const HomeScreenHeader(),

                  SizedBox(height: size.height * 0.08),

                  ControlButtons(
                    isTimerMode: _isTimerMode,
                    onContinuousTap: () {
                      print('DEBUG: Continuous button tapped!');
                      if (_isTimerMode) _toggleTimerMode();
                    },
                    onTimerTap: () {
                      print('DEBUG: Timer button tapped!');
                      _showTimerModal();
                    },
                  ),

                  SizedBox(height: size.height * 0.02),

                  Expanded(
                    child: TrackListWidget(
                      tracks: _tracks,
                      selectedTrackIndex: _selectedTrackIndex,
                      isPlaying: _isPlaying,
                      isPaused: _isPaused,
                      isFirstLaunch: _isFirstLaunch,
                      isTimerMode: _isTimerMode,
                      remainingTime: _remainingTime,
                      blinkAnimation: _blinkAnimation,
                      onTrackTap: _togglePlayPause,
                    ),
                  ),

                  BottomBar(
                    volume: _volume,
                    onVolumeChanged: _changeVolume,
                    onSettingsTap: _openSettingsModal,
                  ),
                ],
              ),

              // 5?? Volume bar
              VolumeBar(
                volume: _volume,
                onVolumeChanged: _changeVolume,
              ),

              // 6?? Positioned tagline
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
}
