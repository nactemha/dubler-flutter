import 'package:flutter/material.dart';
import 'TestPageWidget.dart';

void main() async {
  runApp(TestAppWidget());
  print("after run");
}

class TestAppWidget extends StatelessWidget {
  TestAppWidget({super.key}) {
    setup();
  }

  Future setup() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TestPageWidget(title: 'Flutter Demo Home Page'));
  }
}
