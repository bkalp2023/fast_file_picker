import 'dart:io';

import 'package:accessing_security_scoped_resource/accessing_security_scoped_resource.dart';
import 'package:fast_file_picker/fast_file_picker.dart';

final _plugin = AccessingSecurityScopedResource();

extension FastFilePickerPathExtension on FastFilePickerPath {
  Future<void> accessAppleScopedResource(
      Future<void> Function(bool hasAccess, FastFilePickerPath pickerPath)
          action) async {
    if (uri == null || path == null) {
      return;
    }
    if (!Platform.isIOS && !Platform.isMacOS) {
      return;
    }
    bool hasAccess = false;
    try {
      hasAccess =
          await _plugin.startAccessingSecurityScopedResourceWithURL(uri!);
      await action(hasAccess, this);
    } finally {
      if (hasAccess) {
        await _plugin.stopAccessingSecurityScopedResourceWithURL(uri!);
      }
    }
  }
}
