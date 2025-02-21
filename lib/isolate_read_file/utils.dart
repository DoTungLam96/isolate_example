import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  Utils._();

  static final I = Utils._();

  Future<PermissionStatus> requestPermissionStorage() async {
    Permission permission = Permission.storage;

    if (Platform.isIOS) {
      permission = Permission.storage;
    } else if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();

      final info = await deviceInfo.androidInfo;

      final osVersion = info.version.sdkInt;

      if (osVersion >= 33) {
        permission = Permission.photos;
      } else {
        permission = Permission.storage;
      }
    }

    final status = await permission.request();

    return status;
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }
}
