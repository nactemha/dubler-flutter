import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class MediaVM extends ChangeNotifier {
  late VideoPlayerController _controller;
  var _ready = false;
  get ready => _ready;
  get duration => _controller.value.duration;
  Duration get position => _controller.value.position;
  get aspectRatio => _controller.value.aspectRatio;
  VideoPlayer createVideoPlayer() {
    return VideoPlayer(_controller);
  }

  bool _isPlaying() {
    if (!_ready) {
      return false;
    }
    return _controller.value.isPlaying;
  }

  bool get playing => _isPlaying();
  void playToggle() {
    if (_ready) {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      notifyListeners();
    }
  }

  Future load(String url) async {
    _controller = VideoPlayerController.network(url);
    _controller.addListener(() {
      notifyListeners();
    });
    await _controller.initialize();
    _ready = true;
    notifyListeners();
  }

  void seekTo(int timestamp) {
    _controller.seekTo(Duration(milliseconds: timestamp));
  }
}
