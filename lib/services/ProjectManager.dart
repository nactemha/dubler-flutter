import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:dubbler/services/SubtitleUtil.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/session_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:subtitle/subtitle.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VoiceInfo {
  String text;
  String language;
  String fileName;
  Duration offset;
  Duration duration = Duration.zero;
  double volume = 1.0;
  VoiceInfo({
    required this.text,
    required this.language,
    required this.fileName,
    required this.offset,
    required this.duration,
    this.volume = 1.0,
  });
  Map toJson() => {
        "text": text,
        "language": language,
        "fileName": fileName,
        "offset": offset.inMilliseconds,
        "duration": duration.inMilliseconds,
        "volume": volume,
      };
  factory VoiceInfo.fromJson(Map<String, dynamic> json) {
    return VoiceInfo(
      text: json['text'],
      language: json['language'],
      fileName: json['fileName'],
      offset: Duration(milliseconds: json['offset']),
      duration: Duration(milliseconds: json['duration']),
      volume: json['volume'],
    );
  }
}

class ProjectInfo {
  String name;
  String id;
  DateTime created;
  ProjectInfo({
    required this.name,
    required this.id,
    required this.created,
  });
}

class ProjectManager extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isRendering = false;
  bool get isRendering => _isRendering;
  DateTime _renderTime = DateTime.now();
  DateTime get renderTime => _renderTime;

  dynamic meta = {
    "name": Null,
    "voices": <VoiceInfo>[],
    "sourceMediaVolume": 1.0,
    "sourceMediaPath": "",
    "ext": "",
    "created": DateTime.now().toIso8601String(),
    "language": "en",
  };
  late Directory _baseFolder;
  late Directory _projectFolder;
  final mediaStorePlugin = MediaStore();

  Future setUp() async {
    _isLoading = true;
    notifyListeners();
    MediaStore.appFolder = "dubler";

    _baseFolder = await getApplicationSupportDirectory();
    _baseFolder = Directory("${_baseFolder.path}/projects/");
    if (!(await _baseFolder.exists())) {
      _baseFolder.create();
    }
    _isLoading = false;
  }

  double get sourceMediaVolume => getMeta("sourceMediaVolume");
  set sourceMediaVolume(double value) {
    setMeta("sourceMediaVolume", value);
    notifyListeners();
  }

  String get sourceMediaPath => getMeta("sourceMediaPath");
  set _sourceMediaPath(String value) {
    setMeta("sourceMediaPath", value);
    notifyListeners();
  }

  String get fileExt => getMeta("ext");
  set _fileExt(String value) {
    setMeta("ext", value);
    notifyListeners();
  }

  String get subtitleFiles => getMeta("subtitle_files");
  set _subtitleFiles(String value) {
    setMeta("subtitle_files", value);
    notifyListeners();
  }

  String get language => getMeta("language");

  String get subtitleFilePath => "${_projectFolder.path}/voices.srt";

  String get renderedMediaPath => "${_projectFolder.path}/rendered.$fileExt";

  Future<bool> export() async {
    var renderedFilePath = "${_projectFolder.path}/rendered.$fileExt";
    var now = DateTime.now();
    var timeappendix =
        "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
    var renamedFilePath =
        "${_projectFolder.path}/dubler_$timeappendix.$fileExt";
    await File(renderedFilePath).rename(renamedFilePath);
    var result = await mediaStorePlugin.saveFile(
        tempFilePath: renamedFilePath!,
        dirType: DirType.video,
        dirName: DirType.video.defaults);

    return result;
  }

  Future<PlatformFile?> pickMedia() async {
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
      return result.files.single;
    }
    return null;
  }

  Future loadMeta() async {
    var filePath = '${_projectFolder.path}/project.json';
    if (await File(filePath).exists()) {
      var f = await File(filePath).readAsString();
      meta = jsonDecode(f, reviver: (key, value) {
        if (key == "voices") {
          return (value as List).map((e) => VoiceInfo.fromJson(e)).toList();
        }
        return value;
      });
      if (meta["voices"] == null) {
        meta["voices"] = [];
      }
    } else {
      throw "Project not found";
    }
    notifyListeners();
  }

  Future saveMeta() async {
    var filePath = '${_projectFolder.path}/project.json';
    await File(filePath)
        .writeAsString(jsonEncode(meta, toEncodable: (dynamic obj) {
      if (obj is VoiceInfo) {
        return obj.toJson();
      }
      return obj;
    }));
  }

  dynamic getMeta(String key) {
    if (meta[key] == null) {
      return null;
    }
    return meta[key];
  }

  void setMeta(String key, dynamic value) {
    meta[key] = value;
    saveMeta();
    notifyListeners();
  }

  Future<String?> create() async {
    var selected = await pickMedia();
    if (selected == null) {
      return null;
    }
    var projectId = const Uuid().v1().toString();
    _projectFolder = Directory('${_baseFolder.path}${projectId}');
    await _projectFolder.create();
    setMeta("name", selected!.name);
    setMeta("ext", selected.extension);
    setMeta("created", DateTime.now().toIso8601String());
    setMeta("sourceMediaPath", selected.path);
    await saveMeta();
    notifyListeners();
    return projectId;
  }

  Future open(String projectId) async {
    _projectFolder = Directory('${_baseFolder.path}$projectId');
    await loadMeta();
    notifyListeners();
  }

  void addVoiceToMeta(VoiceInfo voiceInfo) {
    List<VoiceInfo> voices = getMeta("voices");
    voices.add(voiceInfo);
    setMeta("voices", voices);
    notifyListeners();
  }

  List<VoiceInfo> getVoices() {
    return getMeta("voices");
  }

  Future<Uint8List> _callTTSApi(String text, String language) async {
    var endpoint = '/api/tts/$text';
    var url = Uri.https("dubler.io", endpoint);
    var response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load voice');
    }
    if (response.bodyBytes.length == 0) {
      throw Exception('Failed to load voice');
    }
    if (response.headers['content-type'] != 'audio/wav') {
      throw Exception('Failed to load voice');
    }

    return response.bodyBytes;
  }

  List<ProjectInfo> list() {
    var projects = <ProjectInfo>[];
    for (var entity in _baseFolder.listSync()) {
      if (entity is Directory) {
        var projectFolder = entity;
        var projectMeta = jsonDecode(
            File('${projectFolder.path}/project.json').readAsStringSync());
        projects.add(ProjectInfo(
            id: projectFolder.path.split("/").last,
            name: projectMeta["name"],
            created: DateTime.parse(projectMeta["created"])));
      }
    }
    projects.sort((b, a) => b.created.compareTo(a.created));
    return projects;
  }

  Future<VoiceInfo> addTTS(String text, String language, Duration offset,
      {double? volume}) async {
    var wav = await _callTTSApi(text, language);
    var voiceFileName = '${Uuid().v1().toString()}.wav';
    var voiceFilePath = '${_projectFolder.path}/$voiceFileName';
    await File(voiceFilePath).writeAsBytes(wav);
    var voiceInfo = VoiceInfo(
        text: text,
        language: language,
        fileName: voiceFileName,
        offset: offset,
        duration: const Duration(seconds: 1),
        volume: volume ?? 1.0);
    addVoiceToMeta(voiceInfo);
    notifyListeners();
    return voiceInfo;
  }

  Future removeTTTS(String fileName) async {
    var voices = getMeta("voices") as List<VoiceInfo>;
    var voiceInfo =
        voices.firstWhere((element) => element.fileName == fileName);
    await File('${_projectFolder.path}/${voiceInfo.fileName}').delete();
    voices.remove(voiceInfo);
    setMeta("voices", voices);
    notifyListeners();
  }

  Future updateSubtitleFiles() async {
    var voices = getMeta("voices") as List<VoiceInfo>;
    voices.sort((a, b) => a.offset.compareTo(b.offset));
    var subtitles = <Subtitle>[];
    for (var i = 0; i < voices.length; i++) {
      var voice = voices[i];
      var subtitle = Subtitle(
          index: i,
          start: voice.offset,
          end: voice.offset + voice.duration,
          data: voice.text);

      subtitles.add(subtitle);
    }
    if (await File(subtitleFilePath).exists()) {
      await File(subtitleFilePath).delete();
    }
    var srtString = SubtitleUtil().generateSRT(subtitles);
    await File(subtitleFilePath).writeAsString(srtString);
  }

  Future render({String subtitleRenderMode = ""}) async {
    var voices = getMeta("voices") as List<VoiceInfo>;
    voices.sort((a, b) => a.offset.compareTo(b.offset));

    var source_input = " -i $sourceMediaPath";

    var voices_inputs = "";
    for (var i = 0; i < voices.length; i++) {
      var voice = voices[i];
      var path = "${_projectFolder.path}/${voice.fileName}";
      voices_inputs += " -i ${path}";
    }

    var delays = "";
    //delays += "[0:a]adelay=0:all=true[a0];";
    for (var i = 0; i < voices.length; i++) {
      var voice = voices[i];
      delays +=
          "[${i + 1}:a]adelay=${voice.offset.inMilliseconds}:all=true[a${i + 1}];";
    }

    var amix = "";
    var volumes = "";
    if (sourceMediaVolume != 1.0) {
      volumes += "[0:a]volume=${sourceMediaVolume}[av0];";
      amix += "[av0]";
    } else {
      amix += "[0:a]";
    }
    for (var i = 0; i < voices.length; i++) {
      var voice = voices[i];
      if (voice.volume == 1.0) {
        amix += "[a${i + 1}]";
        continue;
      }
      volumes += "[a${i + 1}]volume=${voice.volume}[av${i + 1}];";
      amix += "[av${i + 1}]";
    }
    amix += "amix=inputs=${voices.length + 1}[outa]";

    var copyVideo = '-c:v copy';
    var videoMap = '-map 0:v:0';
    var audioMap = '-map "[outa]"';

    if (subtitleRenderMode != "") {
      await updateSubtitleFiles();
    }
    var subtitle_input = "";
    var subtitle_map = "";
    var subtitle_codec = "";
    var subtitle_filter = "";
    if (subtitleRenderMode == "burn") {
      subtitle_input = '-vf subtitles=$subtitleFilePath';
      copyVideo = '';
    } else if (subtitleRenderMode == "text") {
      subtitle_input = '-i ${subtitleFilePath}';
      subtitle_map = '-map ${voices.length + 1}:0';
      subtitle_codec = '-c:s mov_text';
    }

    var outputtmppath = "${_projectFolder.path}/renderedtmp.$fileExt";

    var cmd =
        '$source_input $voices_inputs $subtitle_input -filter_complex "$delays$volumes$amix$subtitle_filter" $videoMap $audioMap $subtitle_map $copyVideo $subtitle_codec $outputtmppath';
    //'$inputs $subtitle -filter_complex "$delays $volumes $mix" -map 0:v:0 -map "[outa]" -c:v copy $outputtmppath';

    _isRendering = true;

    var session = await FFmpegKit.execute(cmd);
    // Unique session id created for this execution
    // final sessionId = session.getSessionId();

    // Command arguments as a single string
    // final command = session.getCommand();

    // Command arguments
    //final commandArguments = session.getArguments();

    // State of the execution. Shows whether it is still running or completed
    final state = await session.getState();

    // Return code for completed sessions. Will be undefined if session is still running or FFmpegKit fails to run it
    final returnCode = await session.getReturnCode();

    //final startTime = session.getStartTime();
    //final endTime = await session.getEndTime();
    //final duration = await session.getDuration();

    // Console output generated for this execution
    // final output = await session.getOutput();

    // The stack trace if FFmpegKit fails to run a command
    //final failStackTrace = await session.getFailStackTrace();

    // The list of logs generated for this execution
    final logs = await session.getLogs();
    print(logs);
    print(logs[logs.length - 1].getMessage());

    // The list of statistics generated for this execution (only available on FFmpegSession)
    //final statistics = await (session as FFmpegSession).getStatistics();

    _isRendering = false;
    if (returnCode.toString() != "0") {
      throw Exception('Failed to render');
    }
    if (state == SessionState.completed) {
      if (await File(renderedMediaPath).exists()) {
        await File(renderedMediaPath).delete();
      }
      await File(outputtmppath).rename(renderedMediaPath);
    }
    notifyListeners();
  }
}
