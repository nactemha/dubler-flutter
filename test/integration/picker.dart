import 'dart:ffi';
import 'dart:io';

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
  setUp(() => {});

  test("description", () async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'mp3',
          'wav',
          'ogg',
          'flac',
          'm4a',
          'aac',
          'wma',
          'opus',
          'webm',
          'mp4'
        ],
        allowMultiple: false);

    if (result != null) {
      print(result.files.single.path);
    } else {
      // User canceled the picker
    }
  });
}
