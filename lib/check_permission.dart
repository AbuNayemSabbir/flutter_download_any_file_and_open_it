import 'package:permission_handler/permission_handler.dart';

class CheckPermission {
  isStoragePermission() async {
    var isStorage = await Permission.storage.status;
    var isInstall= await Permission.requestInstallPackages.status;
    if (!isStorage.isGranted && !isInstall.isGranted) {
      await Permission.storage.request();
      await Permission.requestInstallPackages.request();
      if (!isStorage.isGranted && !isInstall.isGranted) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }
}
