import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class DownloadManager {
  Future<Uint8List> getFileContentFromUrl(String url) async {
    final ByteData fileData = await NetworkAssetBundle(Uri.parse(url)).load("");

    Uint8List fileBytes = fileData.buffer
        .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
    return fileBytes;
  }

  Future<String> downloadMedia(String url) async {
    final ByteData fileData = await NetworkAssetBundle(Uri.parse(url)).load("");
    Uint8List fileBytes = fileData.buffer
        .asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);

    String extension = Uri.parse(url).path.split(".").last;

    String filePath =
        await writeToFile(content: fileBytes, extension: extension);

    return filePath;
  }

  Future<File> getTempFile(String extension) async {
    String dir = (await getExternalStorageDirectory())!.path;
    String tempPath =
        "$dir/${DateTime.now().microsecondsSinceEpoch}.$extension";
    File temp = File(tempPath);

    return temp;
  }

  Future<String> writeToFile(
      {required Uint8List content, required String extension}) async {
    final String fileName =
        DateTime.now().microsecondsSinceEpoch.toString() + "." + extension;
    File dest = await getTempFile(p.extension(fileName));

    dest.writeAsBytesSync(content);

    return dest.path;
  }
}
