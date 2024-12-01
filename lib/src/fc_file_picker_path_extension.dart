import 'dart:io';

import 'package:accessing_security_scoped_resource/accessing_security_scoped_resource.dart';
import 'package:fc_file_picker_util/fc_file_picker_util.dart';

final _plugin = AccessingSecurityScopedResource();

extension FcFilePickerPathExtension on FcFilePickerPath {
  Future<void> accessAppleScopedResource(
      Future<void> Function(bool hasAccess, FcFilePickerPath pickerPath)
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
