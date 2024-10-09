# fc_file_picker_util

[![pub package](https://img.shields.io/pub/v/fc_file_picker_util.svg)](https://pub.dev/packages/fc_file_picker_util)

|                  | Windows | macOS | iOS | Android |
| ---------------- | ------- | ----- | --- | ------- |
| Pick files       | ✅      | ✅    | ✅  | ✅      |
| Pick a folder    | ✅      | ✅    | ✅  | ✅      |
| Pick a save path | ✅      | ✅    | ❌  | ❌      |

`fc_file_picker_util` is based on [file_selector](https://pub.dev/packages/file_selector) with the following differences:

- Support picking a folder on iOS, which returns a URL.
- Picking folder on macOS returns both path and URL.
- Picking folder on Android returns an SAF Uri (which supports both internal and external storage).
  - For SAF APIs on Flutter, refer to [saf_stream](https://pub.dev/packages/saf_stream) and [saf_util](https://pub.dev/packages/saf_util).

## Usage

### macOS

You need to add the following key to entitlements in order for macOS app to be able to access file system:

```xml
  <key>com.apple.security.files.user-selected.read-write</key>
  <true/>
```

### Pick a file or multiple files

```dart
/// Picks a file and return a
/// [XFile](https://pub.dev/documentation/cross_file/latest/cross_file/XFile-class.html).
/// If the user cancels the picker, it returns `null`.
final file = await FcFilePickerUtil.pickFile();

/// Picks multiple files and return a list of
/// [XFile](https://pub.dev/documentation/cross_file/latest/cross_file/XFile-class.html).
/// If the user cancels the picker, it returns `null`.
final files = await FcFilePickerUtil.pickMultipleFiles();
```

### Pick a folder

```dart
/// Picks a folder and return a [FcFilePickerXResult].
/// If the user cancels the picker, it returns `null`.
///
/// [writePermission] is only applicable on Android.
final folder = await FcFilePickerUtil.pickFolder(writePermission: true);
```

The result (`FilePickerXResult`) can be a URI or path depending on the platform:

- Windows: path
- macOS: URL if `macOSScoped` is true, otherwise path
- iOS: URL
  - Note: you might need to call [startAccessingSecurityScopedResource](https://pub.dev/packages/accessing_security_scoped_resource) to gain access to the directory on iOS.
- Android: An SAF Uri

### Pick a save path

```dart
/// Picks a save file location and return a [String] path.
/// You can optionally specify a default file name via [defaultName].
/// If the user cancels the picker, it returns `null`.
final savePath = await FcFilePickerUtil.pickSaveFile();
```
