import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dubbler/main.dart' as app;
import 'package:saf/saf.dart';

Future<bool> checkWritePermission() async {
  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      var permissionStatus = await Permission.storage.status;

      switch (permissionStatus) {
        case PermissionStatus.denied:
        case PermissionStatus.permanentlyDenied:
          var test = await Permission.storage.request();
          print(test);
          return false;
        default:
      }
    }
  }
  return true;
}

Future<String> getFileSavePath() async {
  String path = '';
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  print('app documents path: $appDocPath');

  final Directory? externalDir = await getExternalStorageDirectory();
  String externalStoragePath = externalDir!.path;
  print('app external storage path: $externalStoragePath');

  Platform.isAndroid
      ? path = '/storage/emulated/0/Download'
      : path = '$appDocDir.path';

  return path;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => {});

  test("isPermissionGranted", () async {
    app.main();
    var path = await getFileSavePath();
    if (await checkWritePermission()) {
      File file = File('$path/test.txt');
      await file.writeAsString('test');
    }
  });
}
