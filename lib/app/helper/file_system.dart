import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileSystem {
  Future<String> copyImage(File file) async {
    String imgPath = '';

    Directory? externalDirectory = await getExternalStorageDirectory();
    final path = externalDirectory?.path;

    await Directory('$path/Pictures/').create().then((Directory dir) {
      // List<String> splitFilePath = file.path.split('/');
      // String imgName = splitFilePath[splitFilePath.length - 1];
      List<String> splitImgName = file.path.split('.');
      String imgFormat = splitImgName[splitImgName.length - 1];

      imgPath = '$path/Pictures/${DateTime.now()}.$imgFormat';
      file.copy(imgPath);
    });
    return imgPath;
  }
}
