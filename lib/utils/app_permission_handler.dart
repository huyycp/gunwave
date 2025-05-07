// ignore_for_file: unused_import

import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionHandler {
  AppPermissionHandler._internal();

  // static Future<bool> checkPhotoPermission() async {
  //   final Permission permission;
  //   if (Platform.isAndroid) {
  //     final androidInfo = await DeviceInfoPlugin().androidInfo;
  //     permission = androidInfo.version.sdkInt > 32
  //       ? Permission.photos
  //       : Permission.storage; 
  //   } else {
  //     permission = Permission.photos;
  //   }
  //   final status = await permission.status;
  //   if (status != PermissionStatus.granted) {
  //     await openAppSettings();
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }
}