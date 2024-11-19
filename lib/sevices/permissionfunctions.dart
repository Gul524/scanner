import 'package:permission_handler/permission_handler.dart';

class DataPermission {
  static bool PermissionStorage = false;
  static bool PermissionCamera = false;

  static Future<void> requestStoragePermissions() async {
    if (!PermissionStorage) {
      final storagePermission = await Permission.storage.request();
      if (storagePermission.isGranted) {
        DataPermission.PermissionStorage = true;
        print(
            "storage Permission ${DataPermission.PermissionStorage}");
      }
      if (!storagePermission.isGranted) {
        DataPermission.PermissionStorage = false;
        print(
            "storage Permission ${DataPermission.PermissionStorage}");
      }
    }
  }

  static Future<void> requestCameraePermissions() async {
    if (!PermissionCamera) {
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission.isGranted) {
        DataPermission.PermissionCamera = true;
      } else {
        DataPermission.PermissionCamera = false;
      }
    }
  }

  static Future<void> checkCameraPermissions() async {
    final cameraPermission = await Permission.camera.status;
    if (cameraPermission.isGranted) {
      DataPermission.PermissionCamera = true;
      print("camera Permission :  ${DataPermission.PermissionCamera}");
    }
else if (!cameraPermission.isGranted) {
      DataPermission.PermissionCamera = false;
      print("camera Permission :  ${DataPermission.PermissionCamera}");
    }
  }

  static Future<void> checkStoragePermissions() async {
    final storagePermission = await Permission.storage.status;
    if (storagePermission.isGranted) {
      DataPermission.PermissionStorage = true;
      print("storage Permission  ${DataPermission.PermissionStorage}");
    }
     else if (!storagePermission.isGranted) {
      DataPermission.PermissionStorage = false;
      print("storage Permission  ${DataPermission.PermissionStorage}");
    }

  }
}
