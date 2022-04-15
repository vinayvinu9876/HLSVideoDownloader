import 'dart:typed_data';

import 'package:hls_video_player/hlsVideoPlayer/download_manager.dart';
import 'package:m3u_nullsafe/m3u_nullsafe.dart';
import 'dart:io';

class HLSVideoDownloader {
  DownloadManager downloader = DownloadManager();
  Future<String> downloadFile(
      {required String url, required String host}) async {
    List<M3uGenericEntry> entries = await _getFilesList(url);
    BytesBuilder fileContent = BytesBuilder();
    for (M3uGenericEntry entry in entries) {
      if (entry.link.contains(".ts")) {
        String link = "$host/${entry.link}";
        print("downloding link = $link");
        Uint8List fileData = await downloader.getFileContentFromUrl(link);
        fileContent.add(fileData);
      }
    }
    File videoFile = File(await downloader.writeToFile(
        content: fileContent.toBytes(), extension: "ts"));
    return videoFile.path;
  }

  Future<List<M3uGenericEntry>> _getFilesList(String url) async {
    String filePath = await downloader.downloadMedia(url);
    File file = File(filePath);
    final playlist = await M3uParser.parse(file.readAsStringSync());
    print("play list = $playlist");
    return playlist;
  }
}
