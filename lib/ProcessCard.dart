import 'package:flutter/cupertino.dart';

class ProcessCard {
  Duration timestamp;
  String title;
  String description;
  IconData icon;

  String formatTimestamp() {
    var hours = timestamp.inHours;
    var minutes = timestamp.inMinutes - hours * 60;
    var seconds = timestamp.inSeconds - minutes * 60 - hours * 3600;

    var hoursStr = hours.toString().padLeft(2, '0');
    var minutesStr = minutes.toString().padLeft(2, '0');
    var secondsStr = seconds.toString().padLeft(2, '0');
    return "$hoursStr:$minutesStr:$secondsStr";
  }

  ProcessCard(this.timestamp, this.title, this.description, this.icon);
}
