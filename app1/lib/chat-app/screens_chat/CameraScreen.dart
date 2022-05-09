import 'dart:math';

import 'package:app1/chat-app/screens_chat/CameraView.dart';
import 'package:app1/chat-app/screens_chat/VideoView.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

List<CameraDescription>? cameras;

class CameraScreen extends StatefulWidget {
  const CameraScreen(
      {Key? key, this.onImageSend, required this.event, required this.targetId})
      : super(key: key);
  final Function? onImageSend;
  final String event;
  final String targetId;
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController? _cameraController;
  Future<void>? cameraValue;
  late String videoPath = "";
  late bool isRecord = false;

  late bool isFLash = false;
  late bool isCameraFront = true;
  double transform = pi;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cameraController =
        new CameraController(cameras![0], ResolutionPreset.high);
    cameraValue = _cameraController!.initialize();
  }

  @override
  void dispose() {
    super.dispose();

    _cameraController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          FutureBuilder(
              future: cameraValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: CameraPreview(_cameraController!));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 5, bottom: 25),
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //bật flash....................................
                      IconButton(
                          onPressed: () {
                            setState(() {
                              isFLash = !isFLash;
                            });
                            isFLash
                                ? _cameraController!
                                    .setFlashMode(FlashMode.torch)
                                : _cameraController!
                                    .setFlashMode(FlashMode.off);
                          },
                          icon: Icon(
                            isFLash ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 28,
                          )),
                      //chụp quay.................................
                      GestureDetector(
                          onLongPress: () async {
                            final path = join(
                                (await getTemporaryDirectory()).path,
                                "${DateTime.now()}.mp4");
                            await _cameraController!.startVideoRecording();

                            setState(() {
                              isRecord = true;
                              videoPath = path;
                            });
                          },
                          onLongPressUp: () async {
                            final path = join(
                                (await getTemporaryDirectory()).path,
                                "${DateTime.now()}.mp4");
                            XFile video =
                                await _cameraController!.stopVideoRecording();
                            video.saveTo(path);
                            setState(() {
                              isRecord = false;
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) =>
                                        VideoViewPage(path: path)));
                          },
                          onTap: () {
                            if (!isRecord) takePhoto(context);
                          },
                          child: isRecord
                              ? Icon(
                                  Icons.radio_button_on,
                                  color: Colors.red,
                                  size: 80,
                                )
                              : Icon(
                                  Icons.panorama_fish_eye,
                                  color: Colors.white,
                                  size: 70,
                                )),
                      //camera trước..................................
                      IconButton(
                          onPressed: () async {
                            setState(() {
                              isCameraFront = !isCameraFront;
                              transform = transform + pi / 2;
                            });
                            int cameraPos = isCameraFront ? 0 : 1;
                            _cameraController = CameraController(
                                cameras![cameraPos], ResolutionPreset.high);
                            cameraValue = _cameraController!.initialize();
                          },
                          icon: Transform.rotate(
                            angle: transform,
                            child: Icon(
                              Icons.flip_camera_android,
                              color: Colors.white,
                              size: 28,
                            ),
                          ))
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Tap Tap",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  //
  void takePhoto(BuildContext context) async {
    final path =
        join((await getTemporaryDirectory()).path, "${DateTime.now()}.png");
    XFile picture = await _cameraController!.takePicture();
    picture.saveTo(path);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (builder) => CameraViewPage(
                  path: path,
                  event: widget.event,
                  targetId: widget.targetId,
                  onImageSend: widget.onImageSend!,
                )));
  }

  void takeVideo(BuildContext context) async {}
}
