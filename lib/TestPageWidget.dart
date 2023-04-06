import 'package:dubbler/services/ProjectManager.dart';
import 'package:dubbler/TimelineWidget.dart';
import 'package:dubbler/vm/MediaView.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'ControlsWidget.dart';

class TestPageWidget extends StatelessWidget {
  var title;
  TestPageWidget({super.key, this.title}) {
    setup();
  }
  Future setup() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Container(
            child: Column(
          children: [
            RawMaterialButton(onPressed: () async => {}, child: Text("test")),
          ],
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ));
  }
}
