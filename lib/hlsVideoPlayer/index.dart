import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:hls_video_player/hlsVideoPlayer/hls_video_downloader.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class HLSVideoPlayer extends StatefulWidget {
  const HLSVideoPlayer({Key? key}) : super(key: key);
  @override
  State<HLSVideoPlayer> createState() => _HLSVideoPlayer();
}

class _HLSVideoPlayer extends State<HLSVideoPlayer> {
  String host = "https://d3s7ogt3xmdww0.cloudfront.net/628-24-01-introduction";
  final String url =
      'https://d3s7ogt3xmdww0.cloudfront.net/628-24-01-introduction/628-24-01-introduction_360.m3u8';
  VideoPlayerController? videoPlayerController;
  HLSVideoDownloader downloader = HLSVideoDownloader();
  String? errMessage;

  Future<bool> isPermissionGranted() async {
    PermissionStatus status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> playVideo() async {
    try {
      if (!(await isPermissionGranted())) {
        if (mounted) {
          setState(() {
            errMessage = "Storage Permission denied";
          });
        }
        return;
      }

      File videoFile =
          File(await downloader.downloadFile(url: url, host: host));

      if (mounted) {
        setState(() {
          videoPlayerController = VideoPlayerController.file(videoFile);
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          errMessage = e.toString();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      playVideo();
    });
  }

  @override
  void dispose() {
    if (videoPlayerController != null) {
      videoPlayerController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("HLS Video Player"),
            ),
            body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Builder(
                  builder: (context) {
                    if (errMessage != null) {
                      return Text(errMessage ?? "",
                          style: const TextStyle(color: Colors.red));
                    }

                    if (videoPlayerController == null) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: const Center(
                            child: CircularProgressIndicator(
                          color: Colors.blue,
                        )),
                      );
                    }

                    return Chewie(
                        controller: ChewieController(
                      videoPlayerController: videoPlayerController!,
                      autoPlay: true,
                      looping: true,
                    ));
                  },
                ))));
  }
}
