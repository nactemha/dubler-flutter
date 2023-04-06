import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControlsController extends ChangeNotifier {
  ControlsController() {
    _total = Duration.zero;
    _current = Duration.zero;
  }

  Duration _total = Duration.zero;
  Duration _current = Duration.zero;
  get current => _current;
  set current(value) {
    _current = value;
    if (_current > _total) {
      _current = _total;
    }
    notifyListeners();
  }

  Duration get total => _total;
  set total(value) {
    _total = value;
    if (_current > _total) {
      _current = _total;
    }
    notifyListeners();
  }

  bool _isPlaying = false;
  get isPlaying => _isPlaying;
  set isPlaying(value) {
    _isPlaying = value;
    notifyListeners();
  }

  Function playToggle = () {};

  String _formatTimestamp() {
    var hours = _current.inHours;
    var minutes = _current.inMinutes - hours * 60;
    var seconds = _current.inSeconds - minutes * 60 - hours * 3600;

    var hoursStr = hours.toString().padLeft(2, '0');
    var minutesStr = minutes.toString().padLeft(2, '0');
    var secondsStr = seconds.toString().padLeft(2, '0');
    return "$hoursStr:$minutesStr:$secondsStr";
  }

  String get currentTimestamp => _formatTimestamp();

  void Function(Duration duration) seekTo = (duration) => {};
  void Function() addButton = () => {};

  void forward_10() {
    if (_current.inSeconds + 10 > _total.inSeconds) {
      seekTo(_total);
    }
    seekTo(Duration(seconds: _current.inSeconds + 10));
  }

  void forward_30() {
    if (_current.inSeconds + 30 > _total.inSeconds) {
      seekTo(_total);
    }
    seekTo(Duration(seconds: _current.inSeconds + 10));
  }

  void reward_10() {
    if (_current.inSeconds - 10 < 0) {
      seekTo(Duration.zero);
    }
    seekTo(Duration(seconds: _current.inSeconds - 10));
  }

  void reward_1() {
    if (_current.inSeconds - 1 < 0) {
      seekTo(Duration.zero);
    }
    seekTo(Duration(seconds: _current.inSeconds - 1));
  }
}

class ControlsWidget extends StatelessWidget {
  ControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.fast_rewind,
              ),
              iconSize: 30,
              color: Colors.black,
              splashColor: Colors.purple,
              onPressed: () {
                context.read<ControlsController>().reward_10();
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.fast_rewind_outlined,
              ),
              iconSize: 30,
              color: Colors.black,
              splashColor: Colors.purple,
              onPressed: () {
                context.read<ControlsController>().reward_1();
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.add_box,
              ),
              iconSize: 30,
              color: Colors.black,
              splashColor: Colors.purple,
              onPressed: () {
                context.read<ControlsController>().addButton();
              },
            ),
          ),
          Expanded(
              flex: 5,
              child: Consumer<ControlsController>(
                  builder: (context, cart, child) => Text(
                        context.watch<ControlsController>().currentTimestamp,
                        style: TextStyle(
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                      ))),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                context.watch<ControlsController>().isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              iconSize: 30,
              color: Colors.black,
              splashColor: Colors.purple,
              onPressed: () {
                context.read<ControlsController>().playToggle();
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.forward_10,
              ),
              iconSize: 30,
              color: Colors.black,
              splashColor: Colors.purple,
              onPressed: () {
                context.read<ControlsController>().forward_10();
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.forward_30,
              ),
              iconSize: 30,
              color: Colors.black,
              splashColor: Colors.purple,
              onPressed: () {
                context.read<ControlsController>().forward_30();
              },
            ),
          ),
        ],
      ),
    );
  }
}
