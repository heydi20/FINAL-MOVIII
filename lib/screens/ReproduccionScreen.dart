import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _showControls = false;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  String _quality = 'Auto';
  bool _subtitlesEnabled = false;
  Timer? _hideControlsTimer;

  final List<double> _speedOptions = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];
  final List<String> _qualityOptions = [
    'Auto',
    '144p',
    '240p',
    '360p',
    '480p',
    '720p',
    '1080p',
  ];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideThumbnail: true,
        disableDragSeek: false,
      ),
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _showControlsWithTimer() {
    _hideControlsTimer?.cancel();
    setState(() {
      _showControls = true;
    });

    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    _hideControlsTimer?.cancel();
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _seekBackward() {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _controller.seekTo(
      newPosition > Duration.zero ? newPosition : Duration.zero,
    );
  }

  void _seekForward() {
    final currentPosition = _controller.value.position;
    final duration = _controller.value.metaData.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _controller.seekTo(newPosition < duration ? newPosition : duration);
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.deepPurpleAccent.shade400,
                    Colors.deepPurpleAccent.shade700,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSettingCard(
                      icon: Icons.speed,
                      title: "Velocidad",
                      child: DropdownButton<double>(
                        dropdownColor: Colors.deepPurple.shade800,
                        value: _playbackSpeed,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _playbackSpeed = value);
                            setModalState(() => _playbackSpeed = value);
                            _controller.setPlaybackRate(value);
                          }
                        },
                        items: _speedOptions.map((speed) {
                          return DropdownMenuItem(
                            value: speed,
                            child: Text("${speed}x", style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                      ),
                    ),
                    _buildSettingCard(
                      icon: Icons.high_quality,
                      title: "Calidad",
                      child: DropdownButton<String>(
                        dropdownColor: Colors.deepPurple.shade800,
                        value: _quality,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => _quality = value);
                          }
                        },
                        items: _qualityOptions.map((quality) {
                          return DropdownMenuItem(
                            value: quality,
                            child: Text(quality, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                      ),
                    ),
                    _buildSettingCard(
                      icon: Icons.subtitles,
                      title: "Subtítulos",
                      child: Switch(
                        value: _subtitlesEnabled,
                        onChanged: (value) {
                          setState(() => _subtitlesEnabled = value);
                          setModalState(() => _subtitlesEnabled = value);
                        },
                        activeColor: Colors.white,
                      ),
                    ),
                    _buildSettingCard(
                      icon: Icons.volume_up,
                      title: "Volumen ${(_volume * 100).round()}%",
                      child: Slider(
                        value: _volume,
                        onChanged: (value) {
                          setState(() => _volume = value);
                          setModalState(() => _volume = value);
                          _controller.setVolume((_volume * 100).round());
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white30,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 30,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: color ?? Colors.white,
        iconSize: size,
      ),
    );
  }

  Widget _buildControls() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(icon: Icons.replay_10, onPressed: _seekBackward),
                _buildControlButton(
                  icon: _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                    _showControlsWithTimer();
                  },
                  size: 45,
                  color: Colors.deepPurpleAccent,
                ),
                _buildControlButton(icon: Icons.forward_10, onPressed: _seekForward),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _showSettingsModal,
                    icon: const Icon(Icons.settings),
                    color: Colors.white,
                    iconSize: 22,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      _controller.toggleFullScreenMode();
                      _showControlsWithTimer();
                    },
                    icon: const Icon(Icons.fullscreen),
                    color: Colors.white,
                    iconSize: 22,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: _toggleControls,
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.deepPurpleAccent,
                ),
              ),
              // Botón de salir (posición superior)
              Positioned(
                top: 8,
                left: 8,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (_controller.value.isFullScreen) {
                          _controller.toggleFullScreenMode();
                          Future.delayed(const Duration(milliseconds: 300), () {
                            Navigator.of(context).pop();
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ),
              ),
              Positioned.fill(child: _buildControls()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white)),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
