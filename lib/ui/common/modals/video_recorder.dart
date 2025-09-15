// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'package:wonders/common_libs.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/scheduler.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:wonders/ui/common/controls/simple_header.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:video_player/video_player.dart';

/// Camera example home widget.
class VideoRecorderHome extends StatefulWidget {
  final List<CameraDescription> cameras;

  /// Default Constructor
  const VideoRecorderHome({Key? key, required this.cameras}) : super(key: key);
  @override
  State<VideoRecorderHome> createState() {
    return _VideoRecorderHomeState();
  }
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _VideoRecorderHomeState extends State<VideoRecorderHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {

  CameraController? _controller;
  XFile? _videoFile;
  int _seconds = 0;
  late Timer? _timer;

  List<CameraDescription> _cameras = <CameraDescription>[];

  @override
  void initState() {
    super.initState();
    _cameras = widget.cameras;
    _initCamera();
  }

  void _initCamera() async {
    _cameras = widget.cameras;
    CameraController cam_controller = CameraController(_cameras[0], ResolutionPreset.medium);
    await cam_controller.initialize();
    setState(() {
      _controller = cam_controller;
    });
  }

  @override
  void dispose() {
    print("--dispose here----");

    if (_timer != null) {
      _timer!.cancel();
    }

    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      try {
        setState(() {
          _seconds++;
        });
      } catch (e) {
        // Handle the StateError exception if the timer is canceled while it is still active
        print("Error: ${e.toString()}");
      }
    });

  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _seconds = 0;
  }

  Future<void> _startRecording() async {
    print("start recording.......");
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
      //await Future.delayed(Duration(minutes: 1));
      //XFile file = await cameraController.stopVideoRecording();
      //print("recording finish...");
      setState(() {});
      _startTimer();
    } on CameraException catch (e) {
      //_showCameraException(e);
      return;
    } finally {
      //_timer?.cancel();
    }
  }

  void _stopRecording() async {
    print("stop recording.......");

    final CameraController? cameraController = _controller;
    //var appDocDir = await getTemporaryDirectory();
    //String savePath = appDocDir.path + "/temp.mp4";

    _videoFile = await cameraController!.stopVideoRecording();

    if (_videoFile != null) {
      print("--video path---");
      print(_videoFile!.path);

      //final result = await GallerySaver.saveVideo(_videoFile!.path, albumName: 'my_video');
      //print(result);

      setState(() {});
    }

    _stopTimer();
  }

  void _saveRecording() async {
    print("save recording.......");

    if (_videoFile != null) {
      print("--video path---");
      print(_videoFile!.path);

      final result = await GallerySaver.saveVideo(_videoFile!.path, albumName: 'my_video');
      print(result);

      // Store the context in a variable before calling the asynchronous operation
      BuildContext contextToPop = context;

      // Use the stored context variable inside the asynchronous operation
      Future.delayed(Duration.zero, () {
        Navigator.pop(contextToPop);
      });
    }
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
  }

  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    final CameraController? cameraController = _controller;

    if (cameraController == null) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Scaffold(
      //appBar: AppBar(title: Text('Flutter Camera Demo')),
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: Transform.scale(
                scale: _controller!.value.aspectRatio / deviceRatio,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1 / _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: BackBtn().safe(),
          ),
        ],
      ),

      floatingActionButton: Stack(
        children: [
          //Text('Record for $_seconds seconds'),

          Positioned(
              bottom: 0,
              left: 35,
              right: 0,
              child: Column(
                children: [
                  (cameraController.value.isRecordingVideo) ? Positioned(
                    bottom: 0,
                    left: 0,
                    child: Text('$_seconds 秒',
                        style:TextStyle(
                          color: Colors.white,
                          fontFamily: 'Yu Gothic', // set the font family to Noto Sans JP
                          fontSize: 12, // set the font size to 16
                          fontWeight: FontWeight.w600, // set the font weight to 600 (semi-bold)
                        ),
                    ),
                  ): Container(),

                  FloatingActionButton(
                    onPressed: cameraController.value.isRecordingVideo ? _stopRecording : _startRecording,
                    child: Icon(cameraController.value.isRecordingVideo ? Icons.stop : Icons.videocam),
                  ),
                ],
              ),

          ),

          (_videoFile != null && !cameraController.value.isRecordingVideo) ? Positioned(
              bottom: 0,
              right: 0,
              child: RawMaterialButton(
                  onPressed: () {
                    // Do something when the button is pressed
                    _saveRecording();
                  },
                  child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(Icons.save),
                  ),
              )
          ) : Container(),

        ],
      ),
    );
  }
}