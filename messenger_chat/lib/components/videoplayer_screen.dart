import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoplayerScreen extends StatefulWidget {
  final String? videoUrl;

  VideoplayerScreen({required this.videoUrl});

  @override
  State<VideoplayerScreen> createState() => _VideoplayerScreenState();
}

class _VideoplayerScreenState extends State<VideoplayerScreen> {
  late VideoPlayerController _controller;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.contentUri(Uri.parse(widget.videoUrl!))
     ..initialize().then((_){
      setState(() {});
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? GestureDetector(
          onTap: _toggleControlsVisibility,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              if (_showControls)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 60,
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
            ],
          ),
        )
            : CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
