import 'package:dubbler/vm/MediaView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: context.select((MediaVM model) => model.ready)
              ? AspectRatio(
                  aspectRatio:
                      context.select((MediaVM model) => model.aspectRatio),
                  child: context.read<MediaVM>().createVideoPlayer(),
                )
              : Container(),
        ),
      ),
    );
  }
}
