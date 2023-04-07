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

  test("create", () async {
    Stopwatch stopwatch = new Stopwatch()..start();
    var projectId = await projectManager.create();
    print("create took ${stopwatch.elapsedMilliseconds} ms");

    expect(projectId, isNotNull);
    stopwatch.reset();
    await projectManager.addTTS(
        "who is this girl", "en", const Duration(seconds: 1));

    /*await projectManager.addTTS(
        "she looks so beutiful", "en", const Duration(seconds: 3));*/

    /* await projectManager.addTTS(
        "she looks so beutiful", "en", const Duration(seconds: 6));*/

    /* await projectManager.addTTS(
        "she looks so beutiful", "en", const Duration(seconds: 8));*/

    print("tts took ${stopwatch.elapsedMilliseconds} ms");
    stopwatch.reset();
    await projectManager.render();
    print("render took ${stopwatch.elapsedMilliseconds} ms");
    stopwatch.reset();
    var result = await projectManager.export();
    print("export took ${stopwatch.elapsedMilliseconds} ms");
    print('export result $result');
  });
}
