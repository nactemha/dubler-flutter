import 'dart:ffi';
import 'dart:io';

import 'package:dubbler/services/ProjectManager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dubbler/main.dart' as app;
import 'package:saf/saf.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  ProjectManager projectManager = ProjectManager();
  setUp(() async {
    await projectManager.setUp();
  });

  test("open", () async {
    var projectList = await projectManager.list();
    print('project List $projectList');
    var subProject = projectList.first;
    print('subProject $subProject');
    await projectManager.open(subProject.id);
    Stopwatch stopwatch = new Stopwatch()..start();
    await projectManager.addTTS(
        "hey whats app baby", "en", const Duration(seconds: 10));
    await projectManager.addTTS(
        "whats going on ", "en", const Duration(seconds: 20),
        volume: 15);
    await projectManager.addTTS(
        "who is talking", "en", const Duration(seconds: 15));
    print("----------tts took ${stopwatch.elapsedMilliseconds} ms");
    stopwatch.reset();
    await projectManager.render();
    print(
        "----render took-------------------- ${stopwatch.elapsedMilliseconds} ms");
    stopwatch.reset();

    var result = await projectManager.export();

    print("export took ${stopwatch.elapsedMilliseconds} ms");
    print('export result $result');
  });
}
