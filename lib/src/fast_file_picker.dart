import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:ios_document_picker/ios_document_picker.dart';
import 'package:ios_document_picker/ios_document_picker_platform_interface.dart';
import 'package:macos_file_picker/macos_file_picker.dart';
import 'package:saf_util/saf_util.dart';
import 'package:path/path.dart' as p;

/// Represents a picker path that could be either a file path or a URI.
class FastFilePickerPath {
  final String name;
  final String? path;
  final String? uri;

  FastFilePickerPath._(this.name, this.path, this.uri);

  static FastFilePickerPath fromUri(String name, String uri) {
    return FastFilePickerPath._(name, null, uri);
  }

  static FastFilePickerPath fromPath(String name, String path) {
    return FastFilePickerPath._(name, path, null);
  }

  static FastFilePickerPath fromPathAndUri(
      String name, String path, String uri) {
    return FastFilePickerPath._(name, path, uri);
  }

  @override
  String toString() {
    return 'FastFilePickerPath(name: $name, path: $path, uri: $uri)';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'uri': uri,
    };
  }

  FastFilePickerPath.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        path = json['path'] as String?,
        uri = json['uri'] as String?;
}

final SafUtil _safUtil = SafUtil();

class FastFilePicker {
  /// Picks a file and return a [FastFilePickerPath].
  /// If the user cancels the picker, it returns `null`.
  static Future<FastFilePickerPath?> pickFile() async {
    final res = await pickFilesCore();
    return res?.first;
  }

  /// Picks multiple files and return a list of [FastFilePickerPath].
  /// If the user cancels the picker, it returns `null`.
  static Future<List<FastFilePickerPath>?> pickMultipleFiles() async {
    return pickFilesCore(allowsMultiple: true);
  }

  /// Picks a folder and return a [FastFilePickerPath].
  /// If the user cancels the picker, it returns `null`.
  ///
  /// [writePermission] is only applicable on Android.
  /// [useFileSelector] whether to force using the internal file_picker plugin.
  static Future<FastFilePickerPath?> pickFolder({
    required bool writePermission,
    bool? useFileSelector,
  }) async {
    if (Platform.isAndroid && useFileSelector != true) {
      final res =
          await _safUtil.pickDirectory(writePermission: writePermission);
      if (res == null) {
        return null;
      }
      return FastFilePickerPath.fromUri(res.name, res.uri);
    }
    if (Platform.isIOS && useFileSelector != true) {
      final iosPicker = IosDocumentPicker();
      final res =
          (await iosPicker.pick(IosDocumentPickerType.directory))?.first;
      if (res == null) {
        return null;
      }
      return FastFilePickerPath.fromPathAndUri(res.name, res.path, res.url);
    }
    if (Platform.isMacOS && useFileSelector != true) {
      final macosPicker = MacosFilePicker();
      final res = (await macosPicker.pick(MacosFilePickerMode.folder))?.first;
      if (res == null) {
        return null;
      }
      return FastFilePickerPath.fromPathAndUri(res.name, res.path, res.url);
    }

    final folderPath = await getDirectoryPath();
    if (folderPath == null) {
      return null;
    }
    final folderName = p.basename(folderPath);
    return FastFilePickerPath.fromPath(folderName, folderPath);
  }

  /// Picks a save file location and return a [String] path.
  /// You can optionally specify a default file name via [defaultName].
  /// If the user cancels the picker, it returns `null`.
  /// [useFileSelector] whether to force using the internal file_picker plugin.
  static Future<String?> pickSaveFile({
    String? defaultName,
    bool? useFileSelector,
  }) async {
    if (Platform.isMacOS && useFileSelector != true) {
      final macosPicker = MacosFilePicker();
      final res = await macosPicker.pick(MacosFilePickerMode.saveFile,
          defaultName: defaultName);
      if (res == null) {
        return null;
      }
      return res.first.path;
    }
    final res = await getSaveLocation(suggestedName: defaultName);
    return res?.path;
  }

  /// Called by [pickFile] and [pickMultipleFiles].
  ///
  /// [allowsMultiple] if `true`, allows the user to pick multiple files.
  /// [useFileSelector] whether to force using the internal file_picker plugin.
  static Future<List<FastFilePickerPath>?> pickFilesCore({
    bool? allowsMultiple,
    bool? useFileSelector,
  }) async {
    if (Platform.isIOS && useFileSelector != true) {
      final iosPicker = IosDocumentPicker();
      final files = await iosPicker.pick(IosDocumentPickerType.file,
          multiple: allowsMultiple ?? false);
      if (files == null) {
        return null;
      }
      final res = files
          .map((e) => FastFilePickerPath.fromPathAndUri(e.name, e.path, e.url))
          .nonNulls
          .toList();
      return res.isEmpty ? null : res;
    }
    if (Platform.isMacOS && useFileSelector != true) {
      final macosPicker = MacosFilePicker();
      final files = await macosPicker.pick(MacosFilePickerMode.file,
          allowsMultiple: allowsMultiple ?? false);
      if (files == null) {
        return null;
      }
      final res = files
          .map((e) => FastFilePickerPath.fromPathAndUri(e.name, e.path, e.url))
          .nonNulls
          .toList();
      return res.isEmpty ? null : res;
    }
    if (Platform.isAndroid && useFileSelector != true) {
      final files = await _safUtil.pickFiles(multiple: allowsMultiple ?? false);
      if (files == null || files.isEmpty) {
        return null;
      }
      final res =
          files.map((e) => FastFilePickerPath.fromUri(e.name, e.uri)).toList();
      return res.isEmpty ? null : res;
    }

    if (allowsMultiple == true) {
      final files = await openFiles();
      return files.isEmpty
          ? null
          : files
              .map((e) => FastFilePickerPath.fromPath(e.name, e.path))
              .toList();
    }

    final file = await openFile();
    return file == null
        ? null
        : [FastFilePickerPath.fromPath(file.name, file.path)];
  }
}
