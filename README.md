# fc_file_picker_util

[![pub package](https://img.shields.io/pub/v/fc_file_picker_util.svg)](https://pub.dev/packages/fc_file_picker_util)

|                  | Windows | macOS | iOS | Android |
| ---------------- | ------- | ----- | --- | ------- |
| Pick files       | ✅      | ✅    | ✅  | ✅      |
| Pick a folder    | ✅      | ✅    | ✅  | ✅      |
| Pick a save path | ✅      | ✅    | ❌  | ❌      |

File pickers based on [file_selector](https://pub.dev/packages/file_selector) with the following differences:

- Support picking a directory on iOS.
- Picking a directory on macOS can be configured to return a path or a URL.

## Usage

### macOS

You need to add the following key to entitlements in order for macOS app to be able to access file system:

```xml
  <key>com.apple.security.files.user-selected.read-write</key>
  <true/>
```

### Pick files

```dart
/// Picks a file and return a
/// [XFile](https://pub.dev/documentation/cross_file/latest/cross_file/XFile-class.html).
final file = await FcFilePickerUtil.pickFile();

/// Picks multiple files and return a list of
/// [XFile](https://pub.dev/documentation/cross_file/latest/cross_file/XFile-class.html).
final files = await FcFilePickerUtil.pickMultipleFiles();
```

### Pick a folder

```dart
/// Picks a folder and return a [FilePickerXResult].
///
/// [macOSScoped] whether to return URL on macOS. If false, returns path. On iOS,
/// URL is always returned.
final folder = await FcFilePickerUtil.pickFolder(macOSScoped: false);
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
/// You can optionally specify a default file name.
final savePath = await FcFilePickerUtil.pickSaveFile();
```
