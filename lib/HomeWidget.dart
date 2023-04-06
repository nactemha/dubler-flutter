import 'package:dubbler/MediaWidget.dart';
import 'package:dubbler/TimelineWidget.dart';
import 'package:dubbler/vm/MediaView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ControlsWidget.dart';

//create widget with naviator

class HomePageWidget extends StatelessWidget {
  var title;
  HomePageWidget({super.key, this.title}) {
    setup();
  }
  var mediaViewModel = MediaVM();
  var controlController = ControlsController();
  var timelineModel = TimelineModel();

  Future setup() async {
    //await mediaViewModel.load("https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4");
    await mediaViewModel
        .load("https://www.soundhelix.com//examples/mp3/SoundHelix-Song-1.mp3");
    controlController.total = mediaViewModel.duration;
    mediaViewModel.addListener(() {
      controlController.current = mediaViewModel.position;
      controlController.isPlaying = mediaViewModel.playing;
    });
    controlController.seekTo = (timestamp) {
      mediaViewModel.seekTo(timestamp.inMilliseconds);
    };
    controlController.playToggle = () {
      mediaViewModel.playToggle();
    };
    await timelineModel.setup();

    controlController.addButton = () {
      timelineModel.addProcessCard(
          Duration(seconds: 20), "title", "description", Icons.book_online);
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider.value(value: controlController),
      ChangeNotifierProvider.value(value: mediaViewModel),
      ChangeNotifierProvider.value(value: timelineModel),
    ], child: _build(context));
  }

  Widget _build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Container(
            child: Column(
          children: [
            Flexible(flex: 2, child: MediaWidget()),
            Flexible(flex: 1, child: ControlsWidget()),
            Flexible(flex: 6, child: TimelineWidget())
          ],
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            timelineModel.scrollTo(9);
          },
          child: Icon(Icons.add),
        ));
  }
}
