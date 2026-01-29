import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

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
  Duration _timerDuration = const Duration(minutes: 7);
  Duration _remainingTime = const Duration(minutes: 7);
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
        await _audioPlayer.play(AssetSource('audio/djo_end_of_the_beginning.mp3'));

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
    setState(() {
      _isTimerMode = !_isTimerMode;
      if (!_isTimerMode) {
        _timer?.cancel();
        _remainingTime = _timerDuration;
      } else if (_isPlaying) {
        _startTimer();
      }
    });
  }

  // Change volume
  void _changeVolume(double value) {
    setState(() {
      _volume = value;
    });
    _audioPlayer.setVolume(_volume);
  }

  // Format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    //final isTablet= size=>600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/tinnitus_bg.png'),
            fit: BoxFit.cover, // Adjust how the image fits
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
                  SizedBox(height: size.height * 0.02),
                  _buildHeader(),
                  SizedBox(height: size.height * 0.05),
                  _buildControlButtons(),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildTrackList()),

                      ],
                    ),
                  ),
                  _buildSettingsButton(),
                  const SizedBox(height: 20),
                ],
              ),
           _buildVolumeBar(),
           Positioned(
              right: 18,
              top: 85,
              child: Text(
                'earvana',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    const TextSpan(
                      text: 'tinnitus',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'relief',
                      style: TextStyle(color: const Color(0xFF64B5F6)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'professional masking solution',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          // Website

        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Continuous button
          GestureDetector(
            onTap: () {
              if (_isTimerMode) _toggleTimerMode();
            },
            child: Text(
              'continuous',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: !_isTimerMode ? Colors.white : Colors.white54,
                letterSpacing: 1.5,
              ),
            ),
          ),

          const SizedBox(width: 40),

          // Timer button
          GestureDetector(
            onTap: _toggleTimerMode,
            child: Text(
              'timer',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: _isTimerMode ? const Color(0xFF7FFF00) : Colors.white54,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackList() {
    return ListView.builder(
      padding: const EdgeInsets.only(left:18,right: 18),
      itemCount: _tracks.length,
      itemBuilder: (context, index) {
        bool isSelected = _selectedTrackIndex == index;
        bool showAsPlaying = isSelected && _isPlaying;
        bool showAsPaused = isSelected && _isPaused;

        // Color logic
        Color textColor;
        Color iconColor;

        if (_isFirstLaunch) {
          // All black on first launch
          textColor = Colors.black87;
          iconColor = Colors.black54;
        } else if (showAsPlaying) {
          // Green when playing
          textColor = const Color(0xFF7FFF00);
          iconColor = const Color(0xFF7FFF00);
        } else if (showAsPaused) {
          // Yellow when paused (with blink)
          textColor = const Color(0xFFFFD700);
          iconColor = const Color(0xFFFFD700);
        } else {
          // Gray for unselected
          textColor = Colors.white70;
          iconColor = Colors.white54;
        }

        return GestureDetector(
          onTap: () => _togglePlayPause(index),
          child: Container(

            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Play icon
                showAsPaused
                    ? AnimatedBuilder(
                  animation: _blinkAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _blinkAnimation.value,
                      child: Icon(
                        Icons.play_arrow,
                        color: iconColor,
                        size: 24,
                      ),
                    );
                  },
                )
                    : Icon(
                  Icons.play_arrow,
                  color: iconColor,
                  size: 24,
                ),

                const SizedBox(width: 16),

                // Track name
                Expanded(
                  child: Text(
                    _tracks[index]['name']!,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: textColor,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // Loop icon and timer (only for selected track)
                if (isSelected && _isPlaying) ...[
                  Icon(
                    Icons.loop,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  if (_isTimerMode)
                    Text(
                      _formatDuration(_remainingTime),
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: const Color(0xFF7FFF00),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVolumeBar() {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 24, top: 20, bottom: 20),
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
    );
  }

  Widget _buildSettingsButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: IconButton(
          icon: const Icon(
            Icons.settings,
            color: Color(0xFF64B5F6),
            size: 32,
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